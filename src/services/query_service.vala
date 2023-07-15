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

        public async Table db_tablenames (string schema = "public") {
            string stmt = "SELECT rental_date FROM rental;";
            var res = yield _exec_query_internal (stmt);
            
            var table = new Table ((owned) res);

            return table;
        }

        public async string db_version () {

            string stmt = "SELECT version ();";
            var table = yield exec_query (stmt);

            string version = table.data[0][0];

            return version;
        }

        public void connect_db (Connection conn) {
            string db_url = conn.url_form ();
            _active_db = Postgres.connect_db (db_url);
        }

        public async void connect_db_async (Connection conn, out string conn_err) {
            string db_url = conn.url_form ();

            // Hold reference to closure to keep it from being freed whilst
            // thread is active.
            try {
                SourceFunc callback = connect_db_async.callback;
                ThreadFunc<void> run = () => {
                    _active_db = Postgres.connect_db (db_url);

                    // Simulate delay
                    // Thread.usleep (3 * 1000000);
                    var status = _active_db.get_status ();
                    switch (status) {
                    case Postgres.ConnectionStatus.OK:
                        _alive = true;
                        break;
                    case Postgres.ConnectionStatus.BAD:
                        _alive = false;
                        break;
                    default:
                        debug ("Programming error: %s not handled", status.to_string ());
                        break;
                    }


                    Idle.add ((owned) callback);
                };

                var worker = new Worker ("connect database", (owned) run);
                background.add (worker);
            } catch (ThreadError err) {
                debug (err.message);
                return_if_reached ();
            }

            // Wait for background thread to schedule our callback
            yield;
            conn_err = null;
            if (!_alive) {
                conn_err = _active_db.get_error_message ();
            }
        }

        private async Table exec_query (string query) {
            var res = yield _exec_query_internal (query);
            debug (res.get_value (0, 0));

            return new Table ((owned) res);
        }

        private async Result _exec_query_internal (string query) {

            // Boilerplate
            SourceFunc callback = _exec_query_internal.callback;
            Result result = null;
            try {
                ThreadFunc<void> run = () => {
                    // Important line.
                    TimePerf.begin ();

                    debug ("Exec: %s", query);
                    result = _active_db.exec (query);
                    TimePerf.end ();
                    var status = result.get_status ();
                    switch (status) {
                    case ExecStatus.TUPLES_OK:
                        // success
                        break;
                    case ExecStatus.FATAL_ERROR:
                        debug ("Fatal error: %s", result.get_error_message ());
                        break;
                    default:
                        debug ("Programming error: %s not handled", status.to_string ());
                        break;
                    }

                    Idle.add ((owned) callback);
                };

                // Important line.
                var worker = new Worker ("exec query", run);
                background.add (worker);
            } catch (ThreadError err) {
                debug (err.message);
                return_if_reached ();
            }

            yield;

            return (owned) result;
        }

        private Database _active_db;
        // Connection is good and ready to serve query.
        private bool _alive;
        private unowned ThreadPool<Worker> background;
    }
}