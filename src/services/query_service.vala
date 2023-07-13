using Postgres;

namespace Sequelize {
    public class QueryService : Object {

        public QueryService (ThreadPool<Worker> background) {
            Object ();

            this.background = background;
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
                    //  Thread.usleep (3 * 1000000);
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

        public async string db_version () {

            string stmt = "SELECT version ();";
            var res = yield exec_query (stmt);

            string version = res.get_value (0, 0);

            return version;
        }

        private async Result exec_query (string query) {

            // Boilerplate
            SourceFunc callback = exec_query.callback;
            Result result = null;
            try {
                ThreadFunc<void> run = () => {

                    // Important line.
                    result = _active_db.exec (query);
                    switch (result.get_status ()) {
                    case ExecStatus.TUPLES_OK:
                        // success
                        break;
                    default:
                        debug ("Query failed");
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