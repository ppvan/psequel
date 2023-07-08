
using Gee;

namespace Sequelize.View {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/index.ui")]
    public class Index : Gtk.Box {

        Application app;
        ListStore connArray;

        // horizontal

        public Index (Application app) {
            Object ();


            print ("index()\n");

            // foreach (var conn in connArray) {
            // var conn_entry = new ConnEntry (conn.name);
            //// connections is Gtk.ListBox
            // connections.append (conn_entry);
            // }
        }

        construct {

            this.connArray = new ListStore (Type.OBJECT);
            var conn = new Models.Connection ();

            conn_name.set_text (conn.name);
            conn_host.set_text (conn.host);
            conn_port.set_text (conn.port.to_string ());
            conn_user.set_text (conn.user);
            conn_password.set_text (conn.password);
            conn_db.set_text (conn.database);
            conn_use_ssl.set_active (conn.use_ssl);


            // connArray.append (conn);

            connections.bind_model (connArray, (item) => {

                var data = item as Models.Connection;

                var row = new Gtk.ListBoxRow ();

                var conn_entry = new ConnEntry (data);
                row.child = conn_entry;

                return row;
            });
        }

        // UI code

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            // var toast = new Adw.Toast ("Connected");
            // toast.set_timeout (2);

            // overlay.add_toast (toast);

            var conn = new Sequelize.Models.Connection ();
            conn.name = conn_name.get_text ();
            conn.host = conn_host.get_text ();
            conn.port = conn_port.get_text ();
            conn.user = conn_user.get_text ();
            conn.database = conn_db.get_text ();
            conn.password = conn_password.get_text ();
            conn.use_ssl = conn_use_ssl.get_active ();


            if (!conn.valid ()) {
                message.set_text (conn.get_error ());
                return;
            }

            // validate connections

            // save connections

            connArray.append (conn);

            // print("%s\n", connections.selection_mode.)
            print ("The lenth: %u\n", connArray.get_n_items ());

            // try to connect to postgres
        }

        [GtkCallback]
        private void connection_clicked (Gtk.ListBox list, Gtk.ListBoxRow row) {
            var entry = row.get_child () as ConnEntry;

            message.bind_property ("label", conn_name, "text", BindingFlags.DEFAULT);

            // print ("CLicled %s\n", entry.get_label ());
        }

        [GtkChild]
        private unowned Gtk.ListBox connections;

        // [GtkChild]
        // private unowned Gtk.Box sidebar;

        // Inputs binds
        [GtkChild]
        private unowned Adw.EntryRow conn_name;
        [GtkChild]
        private unowned Adw.EntryRow conn_host;
        [GtkChild]
        private unowned Adw.EntryRow conn_port;
        [GtkChild]
        private unowned Adw.EntryRow conn_user;
        [GtkChild]
        private unowned Adw.PasswordEntryRow conn_password;
        [GtkChild]
        private unowned Adw.EntryRow conn_db;
        [GtkChild]
        private unowned Gtk.Switch conn_use_ssl;

        [GtkChild]
        private unowned Gtk.Label message;


        [GtkChild]
        private unowned Adw.ToastOverlay overlay;
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
            this.append (icon);
            this.append (label);
        }
    }
}