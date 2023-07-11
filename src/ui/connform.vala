namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/conn-form.ui")]
    public class ConnectionForm : Gtk.Box {

        BindingGroup binddings;

        private Connection _conn;
        public Connection mapped_conn {
            get {
                return _conn;
            }

            set {
                _conn = value;
                binddings.source = _conn;
            }
        }

        public ConnectionForm () {
            Object ();
        }

        construct {
            print ("%s\n", this.name);

            // Create group to maped the entry widget to connection data.
            this.binddings = new BindingGroup ();
            binddings.bind ("name", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("host", host_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("port", port_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("user", user_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("password", password_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("database", database_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("use_ssl", ssl_switch, "active", SYNC_CREATE | BIDIRECTIONAL);
        }

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            // name_entry.buffer.text = "Hello world";
            mapped_conn.connect_db ();
        }

        [GtkChild]
        private unowned Gtk.Entry name_entry;
        [GtkChild]
        private unowned Gtk.Entry host_entry;
        [GtkChild]
        private unowned Gtk.Entry port_entry;
        [GtkChild]
        private unowned Gtk.Entry user_entry;
        [GtkChild]
        private unowned Gtk.PasswordEntry password_entry;

        [GtkChild]
        private unowned Gtk.Entry database_entry;

        [GtkChild]
        private unowned Gtk.Switch ssl_switch;

        [GtkChild]
        private unowned Gtk.Label info;
    }
}