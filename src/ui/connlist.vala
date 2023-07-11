
namespace Sequelize {


    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/conn-sidebar.ui")]
    public class ConnectionSidebar : Gtk.Box {

        [GtkChild] unowned Gtk.ListBox conn_list;
        ObservableArrayList<Connection> conns;

        public ConnectionSidebar () {
            Object ();
        }

        construct {
            print ("%s\n", this.name);

            conns = new ObservableArrayList<Connection> ();

            if (conns.size == 0) {
                conns.add (new Connection ());
            }

            conn_list.bind_model (conns, row_factory);
            var first_row = conn_list.get_row_at_index (0);
            conn_list.select_row (first_row);
        }

        [GtkCallback]
        public void on_row_selected (Gtk.ListBoxRow? row) {
            if (row == null) {
                return;
            }



            print ("ROw chaned\n");
        }

        [GtkCallback]
        public void on_add_connection (Gtk.Button btn) {
            print ("size = %zu\n", conns.size);

            conns.add (new Connection ());
            var last_row = conn_list.get_row_at_index (conns.size - 1);
            conn_list.select_row (last_row);
        }

        [GtkCallback]
        public void on_remove_connection (Gtk.Button btn) {
            print ("size = %zu\n", conns.size);

            if (conns.size == 0) {
                return;
            }

            var selected = conn_list.get_selected_row ();
            conns.remove_at (selected.get_index ());
            var last_row = conn_list.get_row_at_index (conns.size - 1);
            conn_list.select_row (last_row);
        }


        private void set_up_bindings() {
            
        }

        private Gtk.ListBoxRow row_factory(Object item) {
            if (item is Connection) {
                return new ConnectionRow (item as Connection);
            } else {
                var row = new Gtk.ListBoxRow ();
                row.child = new Gtk.Label ("Not good");
                return row;
            }
        }
    }

    public class ConnectionRow : Gtk.ListBoxRow {

        private Connection _conn_data;

        public Connection conn_data {
            get { return _conn_data; }
            set { this._conn_data = value; }
        }


        public ConnectionRow (Connection conn) {
            Object ();
            this._conn_data = conn;

            build_ui ();
        }

        private void build_ui () {
            //orientation: Gtk.Orientation.HORIZONTAL,
            // spacing: 12,
            // margin_start: 16,
            // height_request: 30
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            box.set_margin_start (16);
            box.set_size_request (-1, 30);

            var icon = new Gtk.Image.from_icon_name ("network-server-database-symbolic");
            var label = new Gtk.Label (conn_data.name);

            conn_data.bind_property ("name", label, "label", BindingFlags.SYNC_CREATE);

            box.append (icon);
            box.append (label);

            child = box;
        }
    }
}