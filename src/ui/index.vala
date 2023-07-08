

namespace Sequelize.View {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/index.ui")]
    public class Index : Gtk.Box {

        Application app;

        // horizontal

        public Index (Application app) {
            this.app = app;
            for (int i = 0; i < 5; i++) {
                var conn = new ConnEntry ("LocalHost " + i.to_string ());
                // connections is Gtk.ListBox
                connections.append (conn);
            }
        }

        construct {
            var conn = new Models.Connection ();

            conn_name.set_text (conn.name);
            conn_host.set_text (conn.host);
            conn_port.set_text (conn.port.to_string ());
            conn_user.set_text (conn.user);
            conn_password.set_text (conn.password);
            conn_db.set_text (conn.database);
            conn_use_ssl.set_active (conn.use_ssl);
        }

        // UI code

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            var toast = new Adw.Toast ("Connected");
            toast.set_timeout (2);

            overlay.add_toast (toast);

            var conn = new Sequelize.Models.Connection ();
            conn.name = conn_name.get_text ();
            conn.host = conn_host.get_text ();
            conn.port = int.parse (conn_port.get_text ());
            conn.user = conn_user.get_text ();
            conn.database = conn_db.get_text ();
            conn.password = conn_password.get_text ();
            conn.use_ssl = conn_use_ssl.get_active ();


            if (!conn.valid ()) {
                message.set_text (conn.get_error ());
            }

            // validate connections

            conn.to_string ();
            // save connections
            // try to connect to postgres
        }

        [GtkCallback]
        private void connection_clicked (Gtk.ListBox list, Gtk.ListBoxRow row) {
            var entry = row.get_child () as ConnEntry;

            print ("CLicled %s\n", entry.get_label ());
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
        private unowned Gtk.Button connect_btn;

        [GtkChild]
        private unowned Gtk.Label message;


        [GtkChild]
        private unowned Adw.ToastOverlay overlay;
    }

    public class ConnEntry : Gtk.Box {

        private Gtk.Label conn_name;

        public ConnEntry (string name) {
            Object (
                    orientation: Gtk.Orientation.HORIZONTAL,
                    spacing: 12,
                    margin_start: 16,
                    height_request: 30
            );

            var icon = new Gtk.Image.from_icon_name ("network-server-database-symbolic");
            this.conn_name = new Gtk.Label (name);


            // box.append (spacer1);
            this.append (icon);
            this.append (conn_name);
        }

        public string get_label () {
            return conn_name.get_label ();
        }
    }
}