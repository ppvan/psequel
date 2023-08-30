namespace Psequel {
    public class ConnectionViewModel : BaseViewModel {
        uint timeout_id = 0;
        public ConnectionRepository repository { get; private set; }
        public SQLService sql_service { get; private set; }
        public NavigationService navigation_service { get; private set; }

        public ObservableList<Connection> connections { get; private set; default = new ObservableList<Connection> (); }
        public Connection? selected_connection { get; set; }

        /** True when trying to establish a connection util know results. */
        public bool is_connectting { get; set; default = false; }

        public ConnectionViewModel (ConnectionRepository repository, SQLService sql_service, NavigationService navigation_service) {
            base ();
            this.repository = repository;
            this.sql_service = sql_service;
            this.navigation_service = navigation_service;

            unowned var loaded_conn = repository.get_connections ();
            connections.extend (loaded_conn);

            if (connections.empty ()) {
                new_connection ();
            }

            // Auto save data each 10 secs in case app crash.
            Timeout.add_seconds (10, () => {
                repository.save ();
                return Source.CONTINUE;
            }, Priority.LOW);
        }

        public void new_connection () {
            var conn = new Connection ();
            repository.append_connection (conn);
            connections.append (conn);
            selected_connection = conn;

            save_connections ();
        }

        public void dupplicate_connection (Connection conn) {
            var clone = conn.clone ();
            clone.name = clone.name + " (copy)";
            repository.append_connection (clone);
            connections.insert (connections.indexof (conn) + 1, clone);
            selected_connection = clone;

            save_connections ();
        }

        public void remove_connection (Connection conn) {
            repository.remove_connection (conn);
            connections.remove (conn);

            save_connections ();
        }

        public void import_connections (List<Connection> connections) {
            repository.append_all (connections);

            this.connections.append_all (connections);
        }

        public async void active_connection (Connection connection) {
            this.is_connectting = true;
            try {
                yield sql_service.connect_db (connection);
                this.navigation_service.navigate (NavigationService.QUERY_VIEW);
                this.emit_event (Event.ACTIVE_CONNECTION, connection);

            } catch (PsequelError err) {
                debug ("Error: %s", err.message);
                create_dialog ("Connection Error", err.message.dup ()).present ();
            }
            this.is_connectting = false;
        }

        public unowned List<Connection> export_connections () {
            return repository.get_connections ();
        }

        public void save_connections () {
            if (timeout_id != 0) {
                Source.remove (timeout_id);
            }

            timeout_id = Timeout.add (500, () => {
                timeout_id = 0;

                // debug ("SAVE: %s", conn.name);
                repository.save ();

                return Source.REMOVE;
            });
        }
    }
}