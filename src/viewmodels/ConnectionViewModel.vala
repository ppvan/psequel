namespace Psequel {
    public class ConnectionViewModel : BaseViewModel {
        uint timeout_id = 0;

        public ObservableList<Connection> connections { get; private set; default = new ObservableList<Connection> (); }
        public ConnectionRepository repository { get; construct; }

        public Connection? selected_connection { get; set; }
        /** True when trying to establish a connection util know results. */
        public bool is_connectting { get; set; default = false; }


        public ConnectionViewModel (ConnectionRepository repository) {
            Object (repository: repository);
        }

        construct {
            unowned var loaded_conn = repository.get_connections ();
            connections.extend (loaded_conn);

            if (connections.empty ()) {
                new_connection ();
            }
            // selected_connection = (Connection)connections.get_item (2);

            //  Auto save data each 10 secs in case app crash.
            Timeout.add_seconds (10, () => {
                repository.save ();
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

        ~ConnectionViewModel () {
            repository.save ();
        }
    }
}