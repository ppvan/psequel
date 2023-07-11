
using Gee;

namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/welcome.ui")]
    public class ConnectionView : Gtk.Box {

        public ConnectionView (Application app) {
            Object ();
        }

        construct {

        }

        [GtkChild]
        private unowned Sequelize.ConnectionForm form;

        [GtkChild]
        private unowned Sequelize.ConnectionSidebar sidebar;
    }
}