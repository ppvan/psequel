
using Gee;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/welcome.ui")]
    public class ConnectionView : Adw.Bin {

        public ConnectionView (Application app) {
            Object ();
        }

        // Connect event.
        construct {
            sidebar.setup_bindings ();
        }


        [GtkChild]
        unowned Psequel.ConnectionSidebar sidebar;
    }
}