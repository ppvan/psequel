using Postgres;

using Gee;
namespace Psequel {
    public class QueryService : Object {

        public int query_limit { get; set; }

        public QueryService (ThreadPool<Worker> background) {
            Object ();
            this.background = background;

            Application.settings.bind ("query-limit", this, "query-limit", SettingsBindFlags.GET);
        }

        public Connection parse_conninfo (string conn_info) throws PsequelError.PARSE_ERROR {

            var conn = new Connection ();

            string err_msg;
            var options = Postgres.parse_conninfo (conn_info, out err_msg);
            if (options == null) {
                throw new PsequelError.PARSE_ERROR (err_msg);
            }

            var cur = options;

            while (cur->keyword != null) {

                if (cur->val == null) {
                    cur++;
                    continue;
                }

                switch (cur->keyword) {
                case "user":
                    conn.user = cur->val;
                    break;
                case "host":
                    conn.host = cur->val;
                    break;

                case "port":
                    conn.port = cur->val;
                    break;

                case "password":
                    conn.password = cur->val;
                    break;

                case "dbname":
                    conn.database = cur->val;
                    break;

                case "sslmode":
                    conn.use_ssl = cur->val == "require" ? true : false;
                    break;
                }

                cur++;
            }

            delete options;

            return conn;
        }

        public async Relation select_v2 (Table table, int page) throws PsequelError {
            string escape_tbname = active_db.escape_identifier (table.name);
            int offset = page * query_limit;

            string stmt = @"SELECT * FROM $escape_tbname LIMIT $query_limit OFFSET $offset";
            return yield exec_query (stmt);
        }

        public async Relation select (string schema, string table_name, int offset = 0, int limit = 500, string where_clause = "") throws PsequelError {

            string escape_tbname = active_db.escape_identifier (table_name);

            string stmt = @"SELECT * FROM $escape_tbname $where_clause LIMIT $limit OFFSET $offset";
            return yield exec_query (stmt);
        }

        public async string db_version () throws PsequelError {

            string stmt = "SELECT version ();";
            var table = yield exec_query (stmt);

            string version = table[0][0];

            return version;
        }

        public async void connect_db (Connection conn) throws PsequelError {
            string db_url = conn.url_form ();
            debug ("Connecting to %s", db_url);
            TimePerf.begin ();
            SourceFunc callback = connect_db.callback;
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

        public async Relation exec_query (string query, out int64 exec_ms = null) throws PsequelError {

            int64 begin = GLib.get_real_time ();
            var result = yield exec_query_internal (query);

            // check query status
            check_query_status (result);

            int64 end = GLib.get_real_time ();
            exec_ms = end - begin;

            var table = new Relation ((owned) result);

            return table;
        }

        public async Relation exec_query_params (string query, Variant[] params) throws PsequelError {


            var result = yield exec_query_params_internal (query, params);

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
            case ExecStatus.EMPTY_QUERY:
                debug ("Empty query");
                throw new PsequelError.QUERY_FAIL ("Empty query");
            default:
                warning ("Programming error: %s not handled", status.to_string ());
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
                warning (err.message);
                assert_not_reached ();
            }
        }

        private async Result exec_query_params_internal (string query, Variant[] params) throws PsequelError {

            int n_params = params.length;
            string[] values = new string[n_params];

            for (int i = 0; i < n_params; i++) {
                if (params[i].is_of_type (VariantType.STRING)) {
                    values[i] = params[i].get_string ();
                } else if (params[i].get_type ().is_basic ()) {
                    values[i] = params[i].print (false);
                } else {
                    warning ("Programming error, got type '%s'", params[i].get_type_string ());
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

                // worker.get_result ();

                TimePerf.end ();

                return (owned) result;
            } catch (ThreadError err) {
                warning (err.message);
                assert_not_reached ();
            }
        }

        private Database active_db;
        private unowned ThreadPool<Worker> background;
    }
}