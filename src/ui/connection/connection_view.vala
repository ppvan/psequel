
using Gee;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {

        public ConnectionViewModel viewmodel {get; set;}
        public ObservableList<Connection> connections {get; set;}
        public Connection? selected_connection {get; set;}

        public ConnectionView (Application app) {
            Object ();
        }

        // Connect event.
        construct {
            debug ("[CONTRUCT] %s", this.name);
        }

        [GtkCallback]
        public void add_new_connection () {
            viewmodel.new_connection ();
        }

        [GtkCallback]
        public void dup_connection (Connection conn) {
            viewmodel.dupplicate_connection (conn);
        }

        [GtkCallback]
        public void remove_connection (Connection conn) {
            viewmodel.remove_connection (conn);
        }

        [GtkCallback]
        public void save_connection (Connection conn) {
            viewmodel.save_connection (conn);
        }
    }
}