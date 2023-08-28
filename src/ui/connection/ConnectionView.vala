
namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {



        public ConnectionViewModel viewmodel { get; set; }

        public signal void request_database (Connection conn);

        public ConnectionView (Application app) {
            Object ();
        }

        // Connect event.
        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_paned (paned);

            debug ("%s", Window.temp.get_type ().name ());
            var container = Window.temp as Psequel.Container;
            viewmodel = container.find_type (typeof (ConnectionViewModel)) as ConnectionViewModel;
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
            viewmodel.is_connectting = true;
            request_database (conn);
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