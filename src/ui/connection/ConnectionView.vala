
namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {

        public ConnectionViewModel viewmodel { get; private set; }

        public ConnectionView (Application app) {
            Object ();
        }

        // Connect event.
        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_paned (paned);
            viewmodel = autowire<ConnectionViewModel> ();
        }

        [GtkCallback]
        public void save_connections () {
            viewmodel.save_connections ();
        }

        [GtkCallback]
        public void add_new_connection () {
            viewmodel.new_connection ();
        }

        [GtkCallback]
        public void active_connection (Connection conn) {
            viewmodel.active_connection.begin (conn);
        }

        [GtkCallback]
        public void dup_connection (Connection conn) {
            viewmodel.dupplicate_connection (conn);
        }

        [GtkCallback]
        public void remove_connection (Connection conn) {
            viewmodel.remove_connection (conn);
        }

        [GtkChild]
        private unowned Gtk.Paned paned;
    }
}