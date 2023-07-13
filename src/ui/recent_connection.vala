
namespace Sequelize {


    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/conn-sidebar.ui")]
    public class ConnectionSidebar : Gtk.Box {

        [GtkChild] unowned Gtk.ListBox conn_list;

        public ConnectionForm form { get; set; }

        public ConnectionSidebar () {
            Object ();
        }

        construct {
            //  print ("%s\n", this.form.name);
            //  setup_bindings ();
        }

        public void setup_bindings () {
            debug ("setup bindings");

            var conns = ResourceManager.instance ().recent_connections;

            // Auto create a conn and focus it on first install.
            if (conns.size == 0) {
                conns.add (new Connection ());
            }

            // Bind the conns model to the list view.
            conn_list.bind_model (conns, row_factory);

            // Auto select created row.
            var first_row = conn_list.get_row_at_index (0);
            conn_list.select_row (first_row);

            debug ("setup bindings done");
        }

        /**
         * If the list view selection changes.
         */
        [GtkCallback]
        public void on_row_selected (Gtk.ListBoxRow? row) {

            var conn_row = row as ConnectionRow;
            if (conn_row == null) {
                return;
            }

            // Bind the selected row to the form.
            form.mapped_conn = conn_row.conn_data;

            debug ("mapped widget binding to another row");
        }

        // On add, create new connection and select it.
        [GtkCallback]
        public void on_add_connection (Gtk.Button btn) {

            var conns = ResourceManager.instance ().recent_connections;
            conns.add (new Connection ());

            debug ("auto select last row");
            var last_row = conn_list.get_row_at_index (conns.size - 1);
            conn_list.select_row (last_row);
        }

        // On remove, remove selected connection and select pos - 1.
        [GtkCallback]
        public void on_remove_connection (Gtk.Button btn) {

            var conns = ResourceManager.instance ().recent_connections;

            if (conns.size <= 0) {
                return;
            }

            var selected = conn_list.get_selected_row ();
            return_if_fail (selected != null);

            int pos = selected.get_index ();
            conns.remove_at (pos);

            debug ("auto select last row");
            var last_row = conn_list.get_row_at_index (pos - 1);
            conn_list.select_row (last_row);
        }

        private Gtk.ListBoxRow row_factory (Object item) {

            if (item is Connection) {
                return new ConnectionRow (item as Connection);
            } else {
                var row = new Gtk.ListBoxRow ();
                row.child = new Gtk.Label ("Not good");
                debug ("Expect Connection, got unknown");
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