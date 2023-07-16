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

        public async Table db_schemas () throws PsequelError {
            var stmt = "select schema_name from information_schema.schemata;";

            var res = yield exec_query (stmt);

            return res;
        }

        public async Table db_tablenames (string schema = "public") throws PsequelError {

            var builder = new StringBuilder ("select tablename from pg_tables where schemaname=");
            builder.append (@"\'$schema\';");

            string stmt = builder.free_and_steal ();
            var res = yield exec_query_internal (stmt);

            var table = new Table ((owned) res);

            return table;
        }

        public async string db_version () throws PsequelError {

            string stmt = "SELECT version ();";
            var table = yield exec_query (stmt);

            // TODO fixme
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
            // Hold reference to closure to keep it from being freed whilst
            // thread is active.
            try {
                SourceFunc callback = connect_db_async.callback;

                ThreadFunc<void> run = () => {
                    active_db = Postgres.connect_db (db_url);

                    // Simulate delay
                    // Thread.usleep (3 * 1000000);
                    Idle.add ((owned) callback);
                };

                var worker = new Worker ("connect database", (owned) run);
                background.add (worker);
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }

            // Wait for background thread to schedule our callback
            yield;
            TimePerf.end ();
            check_connection_status ();
        }

        private async Table exec_query (string query) throws PsequelError {
            var result = yield exec_query_internal (query);

            // check query status
            check_query_status (result);

            var table = new Table ((owned) result);

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
                ThreadFunc<void> run = () => {
                    // Important line.
                    result = active_db.exec (query);
                    Idle.add ((owned) callback);
                };

                // Important line.
                var worker = new Worker ("exec query", run);
                background.add (worker);
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }

            yield;
            TimePerf.end ();

            return (owned) result;
        }

        private async Result exec_query_params_internal (string query, ArrayList<Variant> params) throws PsequelError {

            int n_params = params.size;
            string[] values = new string[n_params];

            // TODO: fixme.
            for (int i = 0; i < n_params; i++) {
                if (params[i].get_type () == VariantType.STRING) {
                    values[i] = params[i].get_string ();
                } else if (params[i].get_type () == VariantType.INT32) {
                    values[i] = params[i].get_int32 ().to_string (int32.FORMAT);
                } else if (params[i].get_type () == VariantType.BOOLEAN) {
                    values[i] = params[i].get_boolean ().to_string ();
                } else if (params[i].get_type () == VariantType.DOUBLE) {
                    values[i] = params[i].get_string ().to_string ();
                } else {
                    debug ("Programming error, got %s", params[i].get_type_string ());
                    assert_not_reached ();
                }
            }

            debug ("Exec Param: %s", query);
            TimePerf.begin ();

            // Boilerplate
            SourceFunc callback = exec_query_params_internal.callback;
            Result result = null;
            try {
                ThreadFunc<void> run = () => {
                    // Important line.
                    result = active_db.exec_params (query, n_params, null, values, null, null, 0);
                    Idle.add ((owned) callback);
                };

                // Important line.
                var worker = new Worker ("exec query params", run);
                background.add (worker);
            } catch (ThreadError err) {
                debug (err.message);
                assert_not_reached ();
            }

            yield;
            TimePerf.end ();

            return (owned) result;
        }

        private Database active_db;
        private unowned ThreadPool<Worker> background;
    }
}