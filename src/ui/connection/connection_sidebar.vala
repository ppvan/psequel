
namespace Psequel {


    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-sidebar.ui")]
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

        public ObservableList<Connection> connections {get; set;}
        public Connection? selected_connection {get; set;}

        public signal void request_new_connection ();
        public signal void request_dup_connection (Connection conn);
        public signal void request_remove_connection (Connection conn);

        public ConnectionSidebar () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (ACTION_ENTRIES, this);
            this.insert_action_group ("conn", action_group);

            selection_model.bind_property ("selected", this, "selected-connection", DEFAULT | BIDIRECTIONAL, from_selected, to_selected);
        }

        // On add, create new connection and select it.
        [GtkCallback]
        public void on_add_connection (Gtk.Button btn) {
            request_new_connection ();
        }

        // [GtkAction]
        private void on_dupplicate_connection () {
            request_dup_connection (selected_connection);
        }

        // [GtkAction]
        private void on_connect_connection () {
            //  viewmodel
            debug ("DEBUG");
        }

        // [GtkAction]
        private void on_remove_connection () {
            request_remove_connection (selected_connection);
        }


        private bool from_selected (Binding binding, Value from, ref Value to) {
            uint pos = from.get_uint ();

            if (pos != Gtk.INVALID_LIST_POSITION) {
                to.set_object (selection_model.get_item (pos));
            }

            return true;
        }

        private bool to_selected (Binding binding, Value from, ref Value to) {

            Connection conn = (Connection)from.get_object ();
            for (uint i = 0; i < selection_model.get_n_items (); i++) {
                if (selection_model.get_item (i) == conn) {
                    to.set_uint (i);
                    return true;
                }
            }

            to.set_uint (Gtk.INVALID_LIST_POSITION);

            return true;
        }


        private void on_import_connection () {
            debug ("Importting connections");
            open_file_dialog.begin ("Import Connections");
        }

        private void on_export_connection () {
            debug ("Exporting connections");
            save_file_dialog.begin ("Export Connections");
        }

        

        private async void save_file_dialog (string title = "Save to file") {

            //  var filter = new Gtk.FileFilter ();
            //  filter.add_suffix ("json");

            //  var filters = new ListStore (typeof (Gtk.FileFilter));
            //  filters.append (filter);

            //  var file_dialog = new Gtk.FileDialog () {
            //      modal = true,
            //      initial_folder = File.new_for_path (Environment.get_home_dir ()),
            //      title = title,
            //      initial_name = "connections",
            //      default_filter = filter,
            //      filters = filters,
            //  };

            //  var content = serialize_connection (this.model);
            //  var bytes = new Bytes.take (content.data); // Move data to byte so it live when out scope
            //  var window = (Window) app.active_window;

            //  try {
            //      var file = yield file_dialog.save (window, null);

            //      yield file.replace_contents_bytes_async (bytes, null, false, FileCreateFlags.NONE, null, null);

            //      var toast = new Adw.Toast ("Data saved successfully.") {
            //          timeout = 2,
            //      };
            //      window.add_toast (toast);
            //  } catch (Error err) {
            //      debug ("can't save file");

            //      var toast = new Adw.Toast (err.message) {
            //          timeout = 3,
            //      };
            //      window.add_toast (toast);
            //  }
        }

        private async void open_file_dialog (string title = "Open File") {
            //  var filter = new Gtk.FileFilter ();
            //  filter.add_mime_type ("application/json");

            //  var window = (Window) app.active_window;

            //  debug (this.name);


            //  var file_dialog = new Gtk.FileDialog () {
            //      modal = true,
            //      initial_folder = File.new_for_path (Environment.get_home_dir ()),
            //      title = title,
            //      initial_name = "connections",
            //      default_filter = filter
            //  };

            //  uint8[] contents;

            //  try {
            //      var file = yield file_dialog.open (window, null);

            //      yield file.load_contents_async (null, out contents, null);

            //      var json_str = (string) contents;
            //      var conns = deserialize_connection (json_str);
            //      this.model.batch_add (conns.iterator ());

            //      var toast = new Adw.Toast (@"Loaded $(conns.size) connections") {
            //          timeout = 3,
            //      };
            //      window.add_toast (toast);
            //  } catch (Error err) {
            //      debug ("Can't load data from file.");

            //      var toast = new Adw.Toast (err.message) {
            //          timeout = 3,
            //      };
            //      window.add_toast (toast);
            //  }
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


        [GtkChild]
        private unowned Gtk.SingleSelection selection_model;
    }

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-row.ui")]
    public class ConnectionRow : Gtk.Box {
        public Connection item {get; set;}
        public uint pos {get; set;}


        [GtkCallback]
        public void on_right_clicked () {
            var list_view = this.parent.parent as Gtk.ListView;
            list_view.model.select_item (pos, true);

            popover.popup ();

        }

        [GtkChild]
        private unowned Gtk.PopoverMenu popover;
    }
}