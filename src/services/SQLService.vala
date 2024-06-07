using Postgres;

namespace Psequel {
/** Main entry poit of application, exec query and return result.
 *
 * Do any thing relate to database, wrapper of libpq
 */
    public class SQLService : Object {
        public int query_limit { get; set; default = 100; }
        public int query_timeout { get; set; }

        private Settings settings;

        public SQLService(ThreadPool<Worker> background){
            Object();
            this.background = background;
            this.settings = autowire<Settings> ();

            settings.bind("query-limit", this, "query-limit", SettingsBindFlags.GET);
            settings.bind("query-timeout", this, "query-timeout", SettingsBindFlags.GET);
        }

        /** Select info from a table. */
        public async Relation select (BaseTable table, int page, int size = query_limit) throws PsequelError {
            string schema_name = active_db.escape_identifier(table.schema.name);
            string escape_tbname = active_db.escape_identifier(table.name);
            int offset = page * size;
            int limit = size;

            string stmt = @"SELECT * FROM $schema_name.$escape_tbname LIMIT $limit OFFSET $offset";
            var query = new Query(stmt);
            return yield exec_query (query);
        }

        public async Relation select_where (BaseTable table, string where_clause, int page, int size = query_limit) throws PsequelError {
            string schema_name = active_db.escape_identifier(table.schema.name);
            string escape_tbname = active_db.escape_identifier(table.name);
            int offset = page * size;
            int limit = size;

            // TODO make a better query builder
            var query_builder = new StringBuilder("SELECT * FROM");
            query_builder.append(@" $schema_name.$escape_tbname ");
            if (where_clause.strip() != "") {
                query_builder.append(@" WHERE $where_clause ");
            }
            query_builder.append(@" LIMIT $limit OFFSET $offset ");

            string stmt = query_builder.free_and_steal();
            var query = new Query(stmt);
            return yield exec_query (query);
        }

        /** Make a connection to database and active connection. */
        public async void connect_db (Connection conn) throws PsequelError {
            var connection_timeout = settings.get_int("connection-timeout");
            var query_timeout = settings.get_int("query-timeout");
            string db_url = conn.connection_string(connection_timeout, query_timeout);
            debug("Connecting to %s", db_url);
            TimePerf.begin();
            SourceFunc callback = connect_db.callback;
            try {
                var worker = new Worker("connect database", () => {
                    active_db = Postgres.connect_db(db_url);

                    // Jump to yield
                    Idle.add((owned) callback);
                });
                background.add(worker);

                yield;
                TimePerf.end();
                check_connection_status();
            } catch (ThreadError err) {
                debug(err.message);
                assert_not_reached();
            }
        }

        public async Relation exec_query (Query query) throws PsequelError {
            int64 begin = GLib.get_real_time();
            var result = yield exec_query_internal (query.sql);

            check_query_status(result);

            int64 end = GLib.get_real_time();

            return new Relation.with_fetch_time((owned) result, end - begin);
        }

        public Relation make_empty_relation (){
            var res = active_db.make_empty_result(ExecStatus.TUPLES_OK);
            return new Relation((owned) res);
        }

        public async Relation exec_query_params (Query query) throws PsequelError {
            assert(query.params != null);

            var result = yield exec_query_params_internal (query.sql, query.params);

            // check query status
            check_query_status(result);

            var table = new Relation((owned) result);

            return table;
        }

        public async void update_row (Table table, Vec<TableField> fields) throws PsequelError {
            var stringBuilder = new StringBuilder("UPDATE ");
            stringBuilder.append(escape_tablename(table));

            var pk_fields = fields.filter((item) => {
                return item.column.is_primarykey;
            });

            var changed_fields = fields.filter((item) => {
                return item.old_value != item.new_value;
            });

            stringBuilder.append(" SET ");

            bool has_changed = false;
            int index = 0;
            string[] params = new string[changed_fields.length + pk_fields.length];
            foreach (var item in changed_fields) {
                has_changed = true;
                index++;
                params[index - 1] = item.new_value;
                stringBuilder.append_printf("%s = $%d,", item.column.name, index);
            }

            if (!has_changed) {
                return;
            }

            stringBuilder.erase(stringBuilder.len - 1, 1); // pop remaining ,

            // Has atleast one primary key to build WHERE clause
            if (pk_fields.length > 0) {
                stringBuilder.append(" WHERE ");
                foreach (var pk in pk_fields) {
                    index++;
                    params[index - 1] = pk.old_value;
                    stringBuilder.append_printf("%s = $%d AND ", pk.column.name, index);
                }

                stringBuilder.erase(stringBuilder.len - 4, 4);
            }

            var query = new Query.with_params(stringBuilder.free_and_steal(), params);

            yield exec_query_params (query);
        }

        private string escape_tablename (Table table){
            string schema_name = active_db.escape_identifier(table.schema.name);
            string escape_tbname = active_db.escape_identifier(table.name);

            return @"$schema_name.$escape_tbname";
        }

        private void check_connection_status () throws PsequelError {
            var status = active_db.get_status();
            switch (status) {
                case Postgres.ConnectionStatus.OK:
                    // Success
                    break;

                case Postgres.ConnectionStatus.BAD:
                    var err_msg = active_db.get_error_message();
                    throw new PsequelError.CONNECTION_ERROR(err_msg);

                default:
                    debug("Programming error: %s not handled", status.to_string());
                    assert_not_reached();
            }
        }

        private void check_query_status (Result result) throws PsequelError {
            var status = result.get_status();

            switch (status) {
                case ExecStatus.TUPLES_OK, ExecStatus.COMMAND_OK, ExecStatus.COPY_OUT:
                    // success
                    break;

                case ExecStatus.FATAL_ERROR:
                    var err_msg = result.get_error_message();
                    debug("Fatal error: %s", err_msg);
                    throw new PsequelError.QUERY_FAIL(err_msg.dup());

                case ExecStatus.EMPTY_QUERY:
                    debug("Empty query");
                    throw new PsequelError.QUERY_FAIL("Empty query");

                default:
                    warning("Programming error: %s not handled", status.to_string());
                    assert_not_reached();
            }
        }

        private async Result exec_query_internal (string query) throws PsequelError {
            debug("Exec: %s", query);
            TimePerf.begin();

            // Boilerplate
            SourceFunc callback = exec_query_internal.callback;
            Result result = null;
            try {
                // Important line.
                var worker = new Worker("exec query", () => {
                    // Important line.
                    result = active_db.exec(query);
                    Idle.add((owned) callback);
                });

                background.add(worker);

                yield;
                TimePerf.end();

                return (owned) result;
            } catch (ThreadError err) {
                warning(err.message);
                assert_not_reached();
            }
        }

        private async Result exec_query_params_internal (string query, Vec<string> params) throws PsequelError {
            debug("Exec Param: %s", query);
            TimePerf.begin();

            SourceFunc callback = exec_query_params_internal.callback;
            Result result = null;


            try {
                var worker = new Worker("exec query params", () => {
                    result = active_db.exec_params(query, (int) params.length, null, params.as_array(), null, null, 0);
                    // Jump to yield
                    Idle.add((owned) callback);
                });
                background.add(worker);
                yield;
                TimePerf.end();

                return (owned) result;
            } catch (ThreadError err) {
                warning(err.message);
                assert_not_reached();
            }
        }

        private Database active_db;
        private unowned ThreadPool<Worker> background;
    }
}
