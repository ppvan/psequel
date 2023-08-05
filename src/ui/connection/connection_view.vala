
using Gee;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {

        const ActionEntry[] ACTIONS = {
            { "import", import_connection },
            { "export", export_connection },
        };

        public ConnectionViewModel viewmodel {get; set;}
        public ObservableList<Connection> connections {get; set;}
        public Connection? selected_connection {get; set;}

        public signal void request_database (Connection conn);

        public ConnectionView (Application app) {
            Object ();
        }



        // Connect event.
        construct {
            debug ("[CONTRUCT] %s", this.name);

            var group = new SimpleActionGroup ();
            group.add_action_entries (ACTIONS, this);
            insert_action_group ("conn", group);
        }

        [GtkCallback]
        public void add_new_connection () {
            viewmodel.new_connection ();
        }

        [GtkCallback]
        public void active_connection (Connection conn) {
            viewmodel.is_connectting = true;
            request_database (conn);
        }

        [GtkCallback]
        public void dup_connection (Connection conn) {
            viewmodel.dupplicate_connection (conn);
        }

        [GtkCallback]
        public void remove_connection (Connection conn) {
            viewmodel.remove_connection (conn);
        }

        [GtkCallback]
        public void save_connection (Connection conn) {
            viewmodel.save_connection (conn);
        }

        public void import_connection () {
            open_file_dialog.begin ("Import connections");
        }

        public void export_connection () {
            save_file_dialog.begin ("Export connections");
        }

        private async void open_file_dialog (string title = "Open File") {
            var filter = new Gtk.FileFilter ();
            filter.add_pattern ("*.json");

            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (filter);

            var window = (Window) get_parrent_window (this);

            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = File.new_for_path (Environment.get_home_dir ()),
                title = title,
                initial_name = "connections",
                default_filter = filter,
                filters = filters
            };

            uint8[] contents;

            try {
                var file = yield file_dialog.open (window, null);

                yield file.load_contents_async (null, out contents, null);
                var json_str = (string) contents;
                var conns = ValueConverter.deserialize_connection (json_str);
                viewmodel.import_connections (conns);

                var toast = new Adw.Toast (@"Loaded $(conns.length ()) connections") {
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

            unowned var conns = viewmodel.export_connections ();
            var content = ValueConverter.serialize_connection (conns);
            var bytes = new Bytes.take (content.data); // Move data to byte so it live when out scope
            var window = (Window) get_parrent_window (this);

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
    }
}