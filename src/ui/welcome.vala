
using Gee;

namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/welcome.ui")]
    public class ConnectionView : Gtk.Box {

        public ConnectionView (Application app) {
            Object ();
        }

        construct {
            sidebar.form = form;

            sidebar.setup_bindings ();
        }

        [GtkChild]
        unowned Sequelize.ConnectionForm form;

        [GtkChild]
        unowned Sequelize.ConnectionSidebar sidebar;
    }
}