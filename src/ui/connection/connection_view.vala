
using Gee;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {

        public void hello () {
            debug ("Hello");
        }

        public ConnectionView (Application app) {
            Object ();

            sidebar = new ConnectionSidebar (this);
            form = new ConnectionForm (this);
        }

        // Connect event.
        construct {
        }


        // [GtkChild]
        private Psequel.ConnectionSidebar sidebar;
        private Psequel.ConnectionForm form;
    }
}