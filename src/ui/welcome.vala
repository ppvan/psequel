
using Gee;

namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/welcome.ui")]
    public class ConnectionView : Adw.Bin {

        public ConnectionView (Application app) {
            Object ();
        }

        construct {
            sidebar.form = form;
            // paned.conn

            sidebar.setup_bindings ();
        }


        [GtkChild]
        unowned Sequelize.ConnectionForm form;

        [GtkChild]
        unowned Sequelize.ConnectionSidebar sidebar;
    }
}