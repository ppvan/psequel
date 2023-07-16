

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {

        private unowned QueryService query_service;
        private unowned AppSignals signals;


        private ObservableArrayList<Table.Row> table_names;

        private Gtk.FilterListModel tablelist_model;
        private Gtk.StringList schema_model;

        public QueryView () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            set_up_table_list ();
            set_up_schema ();
            connect_signals ();
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
            debug ("Search tables: %s", entry.text);
            tablelist_model.get_filter ().changed (Gtk.FilterChange.DIFFERENT);
        }

        [GtkCallback]
        private void on_show_search (Gtk.ToggleButton btn) {
            if (btn.active) {
                search_entry.grab_focus ();
            }
        }

        /**
         * Function update table list when schema changed.
         */
        private void schema_changed () {
            signals.table_list_changed ();
        }

        /**
         * Filter table name base on seach entry.
         */
        private bool search_filter_func (Object item) {
            assert (item is Table.Row);

            var row = item as Table.Row;
            var table_name = row.get (0);
            var search_text = search_entry.text;

            return table_name.contains (search_text);
        }

        /**
         * Reload schema list to the drop down by fetching database.
         */
        private async void reload_schema () throws PsequelError {

            var schema_list = yield query_service.db_schemas ();


            // Clear last item.
            for (int i = 0; i < schema_model.get_n_items (); i++) {
                schema_model.remove (i);
            }

            // db_schemas always return n x 1 table.
            foreach (var item in schema_list) {
                schema_model.append (item[0]);
            }

            debug ("Schema loaded.");
        }

        /**
         * Reload tables list by fetch the database.
         */
        private async void reload_tables () throws PsequelError {

            var cur_schema = ((Gtk.StringObject) schema.selected_item).string ?? "public";

            var relations = yield query_service.db_tablenames (cur_schema);

            table_names.clear ();
            foreach (var item in relations) {
                table_names.add (item);
            }

            debug ("Tables list reloaded, got %d tables in schema %s", table_names.size, cur_schema);
        }

        /** Create row widget from query result.
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

        private void set_up_table_list () {
            this.table_names = new ObservableArrayList<Table.Row> ();

            var filter = new Gtk.CustomFilter (search_filter_func);
            this.tablelist_model = new Gtk.FilterListModel (table_names, filter);
            this.table_list.bind_model (tablelist_model, table_row_factory);
        }

        private void set_up_schema () {
            this.schema_model = new Gtk.StringList (null);
            this.schema.set_model (schema_model);
        }

        private void connect_signals () {
            signals.table_list_changed.connect (() => {
                debug ("Handle table_list_changed.");
                reload_tables.begin ();
            });

            signals.database_connected.connect (() => {
                debug ("Handle database_connected.");
                reload_schema.begin ();
            });

            schema.notify["selected"].connect (schema_changed);
        }

        [GtkChild]
        private unowned Gtk.ListBox table_list;

        [GtkChild]
        private unowned Gtk.SearchEntry search_entry;

        [GtkChild]
        private unowned Gtk.DropDown schema;
    }
}