using Postgres;

using Gee;
namespace Psequel {
    public class QueryService : Object {

        enum ColumnFormat {
            TEXT = 0,
            BINARY
        }

        public QueryService (ThreadPool<Worker> background) {
            Object ();

            this.background = background;
        }

        public async Relation db_schemas () throws PsequelError {
            var stmt = """
            SELECT schema_name FROM information_schema.schemata
            WHERE schema_name NOT IN ('pg_catalog', 'information_schema');
            """;

            var res = yield exec_query (stmt);

            return res;
        }

        public async Relation select (string schema, string table_name, int offset = 0, int limit = 500, string where_clause = "") throws PsequelError {
            
            if (where_clause == "") {
                string stmt = @"SELECT * FROM $schema.$table_name LIMIT $limit OFFSET $offset";
                return yield exec_query (stmt);
            } else {
                string stmt = @"SELECT * FROM $schema.$table_name WHERE $where_clause LIMIT $limit OFFSET $offset";
                return yield exec_query (stmt);
            }


        }

        public async Relation db_table_fk (string schema, string table_name) throws PsequelError {
            string stmt = """
            SELECT conname, pg_catalog.pg_get_constraintdef(r.oid, true) as condef
            FROM pg_catalog.pg_constraint r
            WHERE r.conrelid = $1::regclass AND r.contype = 'f';
            """;

            var params = new ArrayList<Variant> ();
            params.add (new Variant.string (@"$schema.$table_name"));

            var headers = new ArrayList<string> ();
            headers.add_all_array ({
                "Key Name",
                "Columns",
                "Foreign Table",
                "Foreign Columns",
                "On Update",
                "On Delete",
            });

            var raw = yield exec_query_params (stmt, params);
            var result = raw.transform (headers, (old_row) => {
                var new_row = new Relation.Row ();
                new_row.add_field (old_row[0]);

                var fk_def = old_row[1];

                //  Match the index type and column from fk_def
                var regex = /FOREIGN KEY \(([$a-zA-Z_, ]+)\) REFERENCES ([a-zA-Z_, ]+)\(([a-zA-Z_, ]+)\)( ON UPDATE (CASCADE))?( ON DELETE (RESTRICT))?/;
                MatchInfo match_info;
                if (regex.match (fk_def, 0, out match_info)) {

                    new_row.add_field (match_info.fetch (1));
                    new_row.add_field (match_info.fetch (2));
                    new_row.add_field (match_info.fetch (3));
                    new_row.add_field (match_info.fetch (5) == "" ? "NO ACTION" : match_info.fetch (5));
                    new_row.add_field (match_info.fetch (7) == "" ? "NO ACTION" : match_info.fetch (7));
                } else {
                    debug ("Regex not match: %s", fk_def);
                    assert_not_reached ();
                }

                return new_row;
            });


            return result;

        }

        public async Relation db_table_info (string schema, string table_name) throws PsequelError {
            string stmt = """
            SELECT column_name AS "Column Name",
            data_type AS "Type",
            character_maximum_length AS "Length",
            is_nullable AS "Nullable",
            column_default AS "Default Value"

            FROM information_schema.columns
            WHERE table_schema = $1
            AND table_name = $2;
            """;

            var params = new ArrayList<Variant> ();
            params.add (new Variant.string (schema));
            params.add (new Variant.string (table_name));

            return yield exec_query_params (stmt, params);
        }

        public async Relation db_table_indexes (string schema, string table_name) throws PsequelError {
            string stmt = """
            SELECT indexname, indexdef FROM pg_indexes
            WHERE schemaname = $1
            AND tablename = $2;
            """;

            var params = new ArrayList<Variant> ();
            params.add (new Variant.string (schema));
            params.add (new Variant.string (table_name));

            var headers = new ArrayList<string> ();
            headers.add_all_array ({
                "Index Name",
                "Unique",
                "Type",
                "Columns",
            });

            var raw_result = yield exec_query_params (stmt, params);

            var result = raw_result.transform (headers, (old_row) => {
                var new_row = new Relation.Row ();
                new_row.add_field (old_row[0]);

                var indexdef = old_row[1];
                if (indexdef.contains ("UNIQUE")) {
                    new_row.add_field ("YES");
                } else {
                    new_row.add_field ("NO");
                }

                //  Match the index type and column from indexdef, group 1 is type, group 2 is the column list.
                var regex = /USING (btree|hash|gist|spgist|gin|brin|[\w]+) \(([a-zA-Z1-9+\-*\/_, ()]+)\)/;
                MatchInfo match_info;
                if (regex.match (indexdef, 0, out match_info)) {

                    new_row.add_field (match_info.fetch (1));
                    new_row.add_field (match_info.fetch (2));
                } else {
                    debug ("Regex not match: %s", indexdef);
                    assert_not_reached ();
                }

                return new_row;
            });

            return result;
        }

        public async Relation db_tablenames (string schema = "public") throws PsequelError {

            var builder = new StringBuilder ("select tablename from pg_tables where schemaname=");
            builder.append (@"\'$schema\';");

            string stmt = builder.free_and_steal ();
            var res = yield exec_query_internal (stmt);

            var table = new Relation ((owned) res);

            return table;
        }

        public async Relation db_views (string schema = "public") throws PsequelError {

            string stmt = """
            select table_name from INFORMATION_SCHEMA.views WHERE table_schema = $1;
            """;
            var params = new ArrayList<Variant> ();
            params.add (new Variant.string (schema));

            var res = yield exec_query_params_internal (stmt, params);

            var table = new Relation ((owned) res);

            return table;
        }

        public async string db_version () throws PsequelError {

            string stmt = "SELECT version ();";
            var table = yield exec_query (stmt);
            string version = table[0][0];

            return version;
        }

        public void connect_db (Connection conn) {
            string db_url = conn.url_form ();
            active_db = Postgres.connect_db (db_url);
        }

        public async void connect_db_async (Connection conn) throws PsequelError {
            string db_url = conn.url_form ();
            debug ("Connecting to %s", db_url);
            TimePerf.begin ();
            SourceFunc callback = connect_db_async.callback;
            try {
                var worker = new Worker ("connect database", () => {
                    active_db = Postgres.connect_db (db_url);

                    // Jump to yield
                    Idle.add ((owned) callback);
                });
                background.add (worker);

                yield;
                TimePerf.end ();
                check_connection_status ();
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }
        }

        public async Relation exec_query (string query) throws PsequelError {
            var result = yield exec_query_internal (query);

            // check query status
            check_query_status (result);

            var table = new Relation ((owned) result);

            return table;
        }

        public async Relation exec_query_params (string query, ArrayList<Variant> params) throws PsequelError {
            var result = yield exec_query_params_internal (query, params);

            // check query status
            check_query_status (result);

            var table = new Relation ((owned) result);

            return table;
        }

        public async Relation exec_query_params_v2 (string query, Variant[] params) throws PsequelError {
            
            debug (params[0].get_string ());
            
            var result = yield exec_query_params_internal_v2 (query, params);

            // check query status
            check_query_status (result);

            var table = new Relation ((owned) result);

            return table;
        }

        private void check_connection_status () throws PsequelError {
            var status = active_db.get_status ();
            switch (status) {
            case Postgres.ConnectionStatus.OK:
                // Success
                break;
            case Postgres.ConnectionStatus.BAD:
                var err_msg = active_db.get_error_message ();
                throw new PsequelError.CONNECTION_ERROR (err_msg);
            default:
                debug ("Programming error: %s not handled", status.to_string ());
                assert_not_reached ();
            }
        }

        private void check_query_status (Result result) throws PsequelError {

            var status = result.get_status ();

            switch (status) {
            case ExecStatus.TUPLES_OK:
                // success
                break;
            case ExecStatus.FATAL_ERROR:
                var err_msg = result.get_error_message ();
                debug ("Fatal error: %s", err_msg);
                throw new PsequelError.QUERY_FAIL (err_msg.dup ());
            default:
                debug ("Programming error: %s not handled", status.to_string ());
                assert_not_reached ();
            }
        }

        private async Result exec_query_internal (string query) throws PsequelError {

            debug ("Exec: %s", query);
            TimePerf.begin ();

            // Boilerplate
            SourceFunc callback = exec_query_internal.callback;
            Result result = null;
            try {
                // Important line.
                var worker = new Worker ("exec query", () => {
                    // Important line.
                    result = active_db.exec (query);
                    Idle.add ((owned) callback);
                });

                background.add (worker);

                yield;
                TimePerf.end ();

                return (owned) result;
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }
        }

        private async Result exec_query_params_internal (string query, ArrayList<Variant> params) throws PsequelError {

            int n_params = params.size;
            string[] values = new string[n_params];

            for (int i = 0; i < n_params; i++) {
                if (params[i].is_of_type (VariantType.STRING)) {
                    values[i] = params[i].get_string ();
                } else if (params[i].get_type ().is_basic ()) {
                    values[i] = params[i].print (false);
                } else {
                    debug ("Programming error, got type '%s'", params[i].get_type_string ());
                    assert_not_reached ();
                }
            }

            debug ("Exec Param: %s", query);
            TimePerf.begin ();

            SourceFunc callback = exec_query_params_internal.callback;
            Result result = null;

            try {
                var worker = new Worker ("exec query params", () => {
                    result = active_db.exec_params (query, n_params, null, values, null, null, 0);
                    // Jump to yield
                    Idle.add ((owned) callback);
                });
                background.add (worker);

                yield;

                //  worker.get_result ();

                TimePerf.end ();

                return (owned) result;
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }

        }

        private async Result exec_query_params_internal_v2 (string query, Variant[] params) throws PsequelError {

            int n_params = params.length;
            string[] values = new string[n_params];

            for (int i = 0; i < n_params; i++) {
                if (params[i].is_of_type (VariantType.STRING)) {
                    values[i] = params[i].get_string ();
                } else if (params[i].get_type ().is_basic ()) {
                    values[i] = params[i].print (false);
                } else {
                    debug ("Programming error, got type '%s'", params[i].get_type_string ());
                    assert_not_reached ();
                }
            }

            debug ("Exec Param: %s", query);
            TimePerf.begin ();

            SourceFunc callback = exec_query_params_internal_v2.callback;
            Result result = null;

            try {
                var worker = new Worker ("exec query params", () => {
                    result = active_db.exec_params (query, n_params, null, values, null, null, 0);
                    // Jump to yield
                    Idle.add ((owned) callback);
                });
                background.add (worker);

                yield;

                //  worker.get_result ();

                TimePerf.end ();

                return (owned) result;
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }

        }

        private Database active_db;
        private unowned ThreadPool<Worker> background;
    }
}