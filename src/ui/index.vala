
using Gee;

namespace Sequelize.View {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/index.ui")]
    public class Index : Gtk.Box {

        // horizontal
        private BindingGroup binddings = new BindingGroup ();
        private Models.Connection current;

        public Index (Application app) {
            Object ();

            // name_entry.bind_property ("text", info, "label", BindingFlags.BIDIRECTIONAL);
            // build_ui ();
        }

        construct {

            this.current = new Models.Connection ();
            this.binddings = new BindingGroup ();

            print ("construct\n");
            binddings.bind ("name", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("host", host_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("port", port_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("user", user_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("password", password_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("database", database_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("use_ssl", ssl_switch, "active", SYNC_CREATE | BIDIRECTIONAL);

            binddings.source = current;
        }

        public void build_ui () {

            print ("bindding\n");
            // binddings.bind ("label", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);


            // binddings.source = info;
        }

        [GtkCallback]
        private void on_connect (Gtk.Button btn) {
            // name_entry.buffer.text = "Hello world";
            current.to_string ();
            info.label = "Hello world";
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