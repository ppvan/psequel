
namespace Psequel {


    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-recent.ui")]
    public class ConnectionSidebar : Gtk.Box {


        const ActionEntry[] ACTION_ENTRIES = {
            { "connect", on_connect_connection },
            { "dupplicate", on_dupplicate_connection },
            { "delete", on_remove_connection },
        };

        // Import and export require access to this.model but also have to visible in app menu.
        // So, it's on application action maps
        const ActionEntry[] APP_ACTIONS = {
            { "import", on_import_connection },
            { "export", on_export_connection },
        };

        /** Binded in blueprints file */
        public Window window { get; set; }
        private Application app;

        /* This is null ultil window ready event, which after contruct block */
        private unowned WindowSignals signals;
        private unowned ObservableArrayList<Connection> model;


        public ConnectionSidebar (Window window) {
            Object (window: window);
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);

            with (ResourceManager.instance ()) {
                this.app = app;
                this.model = recent_connections;
                app_signals.window_ready.connect (setup_signals);
            }
        }

        private void setup_signals () {
            signals = window.signals;
            this.setup_bindings ();
            this.setup_action ();
        }

        private void setup_action () {
            debug ("setup_action");

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (ACTION_ENTRIES, this);
            this.insert_action_group ("conn", action_group);

            app.add_action_entries (APP_ACTIONS, this);
        }

        public void setup_bindings () {
            debug ("setup bindings");

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

            // Emit connection changed for any one subcribe to it.
            signals.selection_changed (conn_row.conn_data);

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

        private void on_import_connection () {
            debug ("Importting connections");
            open_file_dialog.begin ("Import Connections");
        }

        private void on_export_connection () {
            debug ("Exporting connections");
            save_file_dialog.begin ("Export Connections");
        }

        private void on_dupplicate_connection () {
            debug ("on_dupplicate_connection");
            dupplicate_connection ();
        }

        private void on_connect_connection () {
            debug ("on_connect_connection");
            request_connect_database ();
        }

        private void on_remove_connection () {
            debug ("on_delete_connection");
            remove_connection ();
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

            var window = (Window) app.active_window;

            debug (this.name);


            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = File.new_for_path (Environment.get_home_dir ()),
                title = title,
                initial_name = "connections",
                default_filter = filter
            };

            uint8[] contents;

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

        private void remove_connection () {
            if (model.size <= 0) {
                return;
            }

            var selected = conn_list.get_selected_row ();
            assert_nonnull (selected);

            int pos = selected.get_index ();
            model.remove_at (pos);

            debug ("auto select last row");
            var last_row = conn_list.get_row_at_index (pos - 1);
            conn_list.select_row (last_row);
        }

        private void dupplicate_connection () {

            if (model.size <= 0) {
                return;
            }

            var selected = conn_list.get_selected_row ();
            assert_nonnull (selected);

            int pos = selected.get_index ();

            var dupp = model[pos].clone ();
            model.insert (dupp, pos + 1);
        }

        private void request_connect_database () {
            var selected = conn_list.get_selected_row ();
            // Selection mode must be browse (only 1 selection)
            assert_nonnull (selected);
            var conn = model.get (selected.get_index ());

            signals.request_database_conn (conn);
        }

        [GtkChild]
        private unowned Gtk.ListBox conn_list;
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