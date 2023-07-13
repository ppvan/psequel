
using Gee;

namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/welcome.ui")]
    public class ConnectionView : Adw.Bin {

        public ConnectionView (Application app) {
            Object ();
        }

        // Connect event.
        construct {
            sidebar.setup_bindings ();
        }


        [GtkChild]
        unowned Sequelize.ConnectionForm form;

        [GtkChild]
        unowned Sequelize.ConnectionSidebar sidebar;
    }
}