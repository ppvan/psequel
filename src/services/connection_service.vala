using Postgres;

namespace Sequelize {
    public class ConnectionService: Object {
        public Connection connection {
            get; construct;
        }


        public ConnectionService (Connection conn) {
            Object (connection: conn);
        }

        public async void connect_db () {
            string db_url = connection.url_form ();
            _active_db = Postgres.connect_db (db_url);
        }

        private Database _active_db;
    }
}