

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {

        private unowned QueryService query_service;
        private unowned AppSignals signals;


        private ObservableArrayList<Table.Row> table_names;
        private Gtk.FilterListModel model;

        public QueryView () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;


            table_names = new ObservableArrayList<Table.Row> ();

            var filter = new Gtk.CustomFilter (search_filter_func);
            this.model = new Gtk.FilterListModel (table_names, filter);
            this.table_list.bind_model (model, table_row_factory);


            signals.table_list_changed.connect (() => {
                debug ("Handle table_list_changed.");
                reload_tables.begin ();
            });

            signals.database_connected.connect (() => {
                debug ("Handle database_connected.");
                reload_schema.begin ();
            });
        }

        [GtkCallback]
        private void on_reload_clicked () {

            debug ("Emit table_list_changed");
            signals.table_list_changed ();
        }

        [GtkCallback]
        private void on_logout_clicked () {

            var window = (Window) ResourceManager.instance ().app.get_active_window ();
            window.navigate_to ("connection-view");
        }

        [GtkCallback]
        private void on_search (Gtk.SearchEntry entry) {
            debug (entry.text);
            model.get_filter ().changed (Gtk.FilterChange.DIFFERENT);
        }

        [GtkCallback]
        private void on_show_search (Gtk.ToggleButton btn) {
            if (btn.active) {
                search_entry.grab_focus ();
            }
        }

        [GtkCallback]
        private void schema_changed (Gtk.ComboBox box) {
            signals.table_list_changed ();
        }

        private bool search_filter_func (Object item) {
            assert (item is Table.Row);

            var row = item as Table.Row;
            var table_name = row.get (0);
            var search_text = search_entry.text;

            return table_name.contains (search_text);
        }

        private async void reload_schema () throws PsequelError {

            var relations = yield query_service.db_schemas ();

            foreach (var row in relations) {
                var smname = row[0];
                if (smname == "public") {
                    schema.prepend_text (smname);
                    continue;
                }
                schema.append_text (smname);
            }

            // Select public as default.
            schema.set_active (0);
        }

        private async void reload_tables () throws PsequelError {

            var cur_schema = schema.get_active_text () ?? "public";

            // debug (cur_schema.to_string ());

            var relations = yield query_service.db_tablenames (cur_schema);

            table_names.clear ();
            foreach (var item in relations) {
                table_names.add (item);
            }
        }

        /** Create row widget from data
         */
        private Gtk.ListBoxRow table_row_factory (Object obj) {
            var row_data = obj as Table.Row;

            var row = new Gtk.ListBoxRow ();

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
            var icon = new Gtk.Image ();
            icon.icon_name = "table-symbolic";
            var label = new Gtk.Label (row_data[0]);

            box.append (icon);
            box.append (label);

            row.child = box;

            return row;
        }

        [GtkChild]
        private unowned Gtk.ListBox table_list;

        [GtkChild]
        private unowned Gtk.SearchEntry search_entry;

        [GtkChild]
        private unowned Gtk.ComboBoxText schema;
    }
}