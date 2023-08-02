
using Gee;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {

        public Window window {get; set;}

        public ConnectionView (Application app) {
            Object ();

            sidebar = new ConnectionSidebar (window);
            form = new ConnectionForm (window);
        }

        // Connect event.
        construct {
            debug ("[CONTRUCT] %s", this.name);
        }


        // [GtkChild]
        private Psequel.ConnectionSidebar sidebar;
        private Psequel.ConnectionForm form;
    }
}