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

        public async Table db_tablenames (string schema = "public") throws PsequelError {
            string stmt = "select tablename from pg_tables where schemaname='public';";
            var res = yield exec_query_internal (stmt);

            var table = new Table ((owned) res);

            return table;
        }

        public async string db_version () throws PsequelError {

            string stmt = "SELECT version ();";
            var table = yield exec_query (stmt);

            // TODO fixme
            string version = "ahihi";

            return version;
        }

        public void connect_db (Connection conn) {
            string db_url = conn.url_form ();
            active_db = Postgres.connect_db (db_url);
        }

        public async void connect_db_async (Connection conn) throws PsequelError {
            string db_url = conn.url_form ();

            string err_msg = null;

            // Hold reference to closure to keep it from being freed whilst
            // thread is active.
            try {
                SourceFunc callback = connect_db_async.callback;

                ThreadFunc<void> run = () => {
                    active_db = Postgres.connect_db (db_url);

                    // Simulate delay
                    // Thread.usleep (3 * 1000000);
                    var status = active_db.get_status ();
                    switch (status) {
                    case Postgres.ConnectionStatus.OK:
                        // Success
                        break;
                    case Postgres.ConnectionStatus.BAD:
                        err_msg = active_db.get_error_message ();
                        break;
                    default:
                        debug ("Programming error: %s not handled", status.to_string ());
                        assert_not_reached ();
                    }


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

            if (err_msg != null) {
                throw new PsequelError.CONNECTION_ERROR (err_msg);
            }
        }

        private async Table exec_query (string query) throws PsequelError {
            var result = yield exec_query_internal (query);

            // check query status
            check_status (result);

            var table = new Table ((owned) result);

            return table;
        }

        private void check_status (Result result) throws PsequelError {

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

            // Boilerplate
            SourceFunc callback = exec_query_internal.callback;
            Result result = null;
            try {
                ThreadFunc<void> run = () => {
                    // Important line.
                    TimePerf.begin ();

                    debug ("Exec: %s", query);
                    result = active_db.exec (query);
                    TimePerf.end ();
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

            return (owned) result;
        }

        private Database active_db;
        private unowned ThreadPool<Worker> background;
    }
}