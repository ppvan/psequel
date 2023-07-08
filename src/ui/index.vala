

namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/index.ui")]
    public class IndexView : Gtk.Box {

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
        private unowned Adw.ToastOverlay overlay;
        // horizontal

        public IndexView () {
            for (int i = 0; i < 5; i++) {
                var conn = new ConnEntry ("LocalHost " + i.to_string ());
                // connections is Gtk.ListBox
                connections.append (conn);
            }
        }

        construct {
            conn_port.set_text (5432.to_string ());
        }

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            var toast = new Adw.Toast ("Connected");
            toast.set_timeout (2);

            overlay.add_toast (toast);
        }

        [GtkCallback]
        private void connection_clicked (Gtk.ListBox list, Gtk.ListBoxRow row) {
            var entry = row.get_child () as ConnEntry;

            print ("CLicled %s\n", entry.get_label ());
        }
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