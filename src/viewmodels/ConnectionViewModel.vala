namespace Psequel {
    public class ConnectionViewModel : BaseViewModel {
        uint timeout_id = 0;

        public ObservableList<Connection> connections {get; private set; default = new ObservableList<Connection> (); }
        public ConnectionRepository repository {get; construct;}

        public Connection? selected_connection {get; set;}
        /** True when trying to establish a connection util know results. */
        public bool is_connectting {get; set; default = false;}


        public ConnectionViewModel (ConnectionRepository repository) {
            Object (repository: repository);
        }

        construct {
            unowned var loaded_conn = repository.get_connections ();
            connections.extend (loaded_conn);
            //  selected_connection = (Connection)connections.get_item (2);
        }

        public void new_connection () {
            var conn = new Connection ();

            repository.append_connection (conn);
            connections.append (conn);
        }

        public void dupplicate_connection (Connection conn) {
            var clone = conn.clone ();
            repository.append_connection (clone);

            connections.insert (connections.indexof (conn) + 1, clone);
        }

        public void remove_connection (Connection conn) {
            repository.remove_connection (conn);

            connections.remove (conn);
        }

        public void import_connections (List<Connection> connections) {
            repository.append_all (connections);

            this.connections.append_all (connections);
        }

        public unowned List<Connection> export_connections () {
            return repository.get_connections ();
        }

        public void save_connection (Connection conn) {
            if (timeout_id != 0) {
                Source.remove (timeout_id);
            }

            timeout_id = Timeout.add (500, () => {
                timeout_id = 0;

                //  debug ("SAVE: %s", conn.name);
                repository.save.begin ();

                return Source.REMOVE;
            });
        }
    }
}