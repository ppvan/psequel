
namespace Psequel {


    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-recent.ui")]
    public class ConnectionSidebar : Gtk.Box {

        [GtkChild] unowned Gtk.ListBox conn_list;

        private Application app;
        private ObservableArrayList<Connection> model;

        public ConnectionForm form { get; set; }

        public ConnectionSidebar () {
            Object ();
        }

        construct {

            this.app = ResourceManager.instance ().app;
            // print ("%s\n", this.form.name);
            // setup_bindings ();
        }

        public void setup_bindings () {
            debug ("setup bindings");

            this.model = ResourceManager.instance ().recent_connections;

            // Auto create a conn and focus it on first install.
            if (model.size == 0) {
                model.add (new Connection ());
            }

            // Bind the conns model to the list view.
            conn_list.bind_model (model, row_factory);

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

        [GtkCallback]
        private void on_import_connection (Gtk.Button btn) {
            debug ("Importting connections");
            open_file_dialog.begin ("Import Connections");
        }

        [GtkCallback]
        private void on_export_connection (Gtk.Button btn) {
            debug ("Exporting connections");
            save_file_dialog.begin ("Export Connections");
        }

        private async void save_file_dialog (string title = "Save to file") {

            var filter = new Gtk.FileFilter ();
            filter.add_suffix ("json");

            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (filter);

            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = File.new_for_path (Environment.get_home_dir ()),
                title = title,
                initial_name = "connections",
                default_filter = filter,
                filters = filters,
            };

            var content = serialize_connection (this.model);
            var bytes = new Bytes.take (content.data); // Move data to byte so it live when out scope
            var window = (Window) app.active_window;

            try {
                var file = yield file_dialog.save (window, null);

                yield file.replace_contents_bytes_async (bytes, null, false, FileCreateFlags.NONE, null, null);

                var toast = new Adw.Toast ("Data saved successfully.") {
                    timeout = 2,
                };
                window.add_toast (toast);
            } catch (Error err) {
                debug ("can't save file");

                var toast = new Adw.Toast (err.message) {
                    timeout = 3,
                };
                window.add_toast (toast);
            }
        }

        private async void open_file_dialog (string title = "Open File") {
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("application/json");
            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = File.new_for_path (Environment.get_home_dir ()),
                title = title,
                initial_name = "connections",
                default_filter = filter
            };

            uint8[] contents;
            var window = (Window) app.active_window;

            try {
                var file = yield file_dialog.open (window, null);

                yield file.load_contents_async (null, out contents, null);

                var json_str = (string) contents;
                var conns = deserialize_connection (json_str);
                this.model.batch_add (conns.iterator ());

                var toast = new Adw.Toast (@"Loaded $(conns.size) connections") {
                    timeout = 3,
                };
                window.add_toast (toast);
            } catch (Error err) {
                debug ("Can't load data from file.");

                var toast = new Adw.Toast (err.message) {
                    timeout = 3,
                };
                window.add_toast (toast);
            }
        }

        private string serialize_connection (ObservableArrayList<Connection> conns) {

            var builder = new Json.Builder ();
            builder.begin_object ();
            builder.set_member_name ("recent_connections");
            builder.begin_array ();

            foreach (var conn in conns) {
                builder.add_value (Json.gobject_serialize (conn));
            }

            builder.end_array ();
            builder.end_object ();

            var node = builder.get_root ();
            return Json.to_string (node, true);
        }

        private ObservableArrayList<Connection> deserialize_connection (string content) {
            var parser = new Json.Parser ();
            var recent_connections = new ObservableArrayList<Connection> ();

            try {
                parser.load_from_data (content);
                var root = parser.get_root ();
                var obj = root.get_object ();
                var conns = obj.get_array_member ("recent_connections");

                conns.foreach_element ((array, index, node) => {
                    var conn = (Connection) Json.gobject_deserialize (typeof (Connection), node);
                    recent_connections.add (conn);
                });
            } catch (Error err) {
                debug (err.message);
                recent_connections.clear ();
            }

            return recent_connections;
        }
    }

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-row.ui")]
    public class ConnectionRow : Gtk.ListBoxRow {

        private Connection _conn_data;

        public Connection conn_data {
            get { return _conn_data; }
            set { this._conn_data = value; }
        }


        public ConnectionRow (Connection conn) {
            Object ();
            this._conn_data = conn;
            conn_data.bind_property ("name", label, "label", BindingFlags.SYNC_CREATE);

            var gesture = new Gtk.GestureClick ();
            gesture.set_button (Gdk.BUTTON_SECONDARY);
            gesture.released.connect (on_right_click);

            this.add_controller (gesture);
            // build_ui ();
        }

        private async void on_right_click () {
            Idle.add (on_right_click.callback);
            yield;

            select_me ();
            pop_up_menu ();
        }

        private void select_me () {
            var listbox = this.parent as Gtk.ListBox;

            listbox.select_row (this);
        }

        private void pop_up_menu () {
            pop_over.popup ();
        }

        [GtkChild]
        private unowned Gtk.Label label;

        [GtkChild]
        private unowned Gtk.PopoverMenu pop_over;
    }
}