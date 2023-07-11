namespace Sequelize {


    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/conn-sidebar.ui")]
    public class ConnectionSidebar : Gtk.Box {
        public ConnectionSidebar() {
            Object();
        }

        [GtkCallback]
        public void on_add_connection(Gtk.Button btn) {

        }

        [GtkCallback]
        public void on_remove_connection(Gtk.Button btn) {

        }

        construct {

        }
    }

    public class ConnEntry : Gtk.Box {

        private Models.Connection _conn_data;

        public Models.Connection conn_data {
            get { return _conn_data; }
            set { this._conn_data = value; }
        }


        public ConnEntry (Models.Connection conn) {
            Object (
                    orientation: Gtk.Orientation.HORIZONTAL,
                    spacing: 12,
                    margin_start: 16,
                    height_request: 30
            );
            this._conn_data = conn;

            build_ui ();
        }

        private void build_ui () {
            var icon = new Gtk.Image.from_icon_name ("network-server-database-symbolic");
            var label = new Gtk.Label (conn_data.name);

            conn_data.bind_property ("name", label, "label", BindingFlags.SYNC_CREATE);

            this.append (icon);
            this.append (label);
        }
    }
}