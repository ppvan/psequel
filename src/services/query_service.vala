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

        public async void connect_db_async (Connection conn) {
            string db_url = conn.url_form ();

            // Hold reference to closure to keep it from being freed whilst
            // thread is active.
            SourceFunc callback = connect_db_async.callback;
            ThreadFunc<void> run = () => {
                _active_db = Postgres.connect_db (db_url);
                Idle.add ((owned) callback);
            };

            var worker = new Worker ("connect database", run);
            background.add (worker);

            // Wait for background thread to schedule our callback
            yield;
        }

        public async string db_version () {
            string stmt = "SELECT version ();";

            string version = null;

            var res = yield exec_query (stmt);
            version = res.get_value (0, 0);


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
        private unowned ThreadPool<Worker> background;
    }
}