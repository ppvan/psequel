

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {

        private unowned QueryService query_service;
        private unowned AppSignals signals;
        private SchemaService schema_service;

        private ObservableArrayList<Schema> schemas;

        private Schema _current_schema;

        private Schema current_schema {
            get {
                return _current_schema;
            }
            set {
                _current_schema = value;
                bind_table_list ();
                bind_views_list ();

                signals.schema_changed (_current_schema);
            }
        }


        private ObservableArrayList<Relation.Row> table_names;
        private ObservableArrayList<Relation.Row> views_names;


        private Gtk.FilterListModel tablelist_model;
        private Gtk.FilterListModel viewslist_model;

        public QueryView () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            schema_service = new SchemaService (query_service);
            schemas = new ObservableArrayList<Schema> ();

            set_up_schema ();
            connect_signals ();
        }


        /**
         * Function update table list when schema changed.
         */
        private void schema_changed () {
            uint index = schema_dropdown.get_selected ();
            current_schema = schemas.get_item (index) as Schema;
        }

        /**
         * Filter table name base on seach entry.
         */
        private bool search_filter_func (Object item) {
            assert (item is Gtk.StringObject);

            var row = item as Gtk.StringObject;
            var table_name = row.string;
            var search_text = search_table_entry.text;

            return table_name.contains (search_text);
        }

        /**
         * Filter table name base on seach entry.
         */
        private bool view_filter_func (Object item) {
            assert (item is Gtk.StringObject);

            var row = item as Gtk.StringObject;
            var view_name = row.string;
            var search_text = search_views_entry.text;

            return view_name.contains (search_text);
        }

        /**
         * Reload schema list to the drop down by fetching database.
         */
        private async void reload_schema () throws PsequelError {

            var schema_list = yield schema_service.schema_list ();

            // Clear last item.
            schemas.clear ();

            for (int i = 0; i < schema_list.length; i++) {
                var cur_schema = yield schema_service.load_schema (schema_list[i]);

                schemas.add (cur_schema);
            }
            debug ("Schema reloaded.");

            uint index = schema_dropdown.get_selected ();
            current_schema = schemas.get_item (index) as Schema;
        }

        /** Create row widget from query result.
         */
        private Gtk.ListBoxRow table_row_factory (Object obj) {
            var row_data = obj as Gtk.StringObject;

            var row = new Gtk.ListBoxRow ();

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
            var icon = new Gtk.Image ();
            icon.icon_name = "table-symbolic";
            var label = new Gtk.Label (row_data.string);

            box.append (icon);
            box.append (label);

            row.child = box;
            row.tooltip_text = "Double click to load data";

            return row;
        }

        private Gtk.ListBoxRow view_row_factory (Object obj) {
            var row_data = obj as Gtk.StringObject;

            var row = new Gtk.ListBoxRow ();

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
            var icon = new Gtk.Image ();
            icon.icon_name = "category-search-symbolic";
            var label = new Gtk.Label (row_data.string);

            box.append (icon);
            box.append (label);

            row.child = box;

            return row;
        }

        private void bind_table_list () {
            var filter = new Gtk.CustomFilter (search_filter_func);
            this.tablelist_model = new Gtk.FilterListModel (current_schema.tablenames, filter);
            this.table_list.bind_model (tablelist_model, table_row_factory);
        }

        private void bind_views_list () {
            var filter = new Gtk.CustomFilter (view_filter_func);
            this.viewslist_model = new Gtk.FilterListModel (current_schema.viewnames, filter);
            this.views_list.bind_model (viewslist_model, view_row_factory);
        }

        private void set_up_schema () {
            //  this.schema_model = new Gtk.StringList (null);
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((_fact, listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((_fact, listitem) => {
                var label = listitem.child as Gtk.Label;
                var item = (listitem.item as Schema);
                label.label = item.name ?? "None";
            });

            this.schema_dropdown.set_factory (factory);
            this.schema_dropdown.set_model (schemas);
        }

        private void connect_signals () {
            //  signals.table_list_changed.connect (() => {
            //      debug ("Handle table_list_changed.");
            //      reload_tables.begin ();
            //  });

            //  signals.views_list_changed.connect (() => {
            //      debug ("Handle views_list_changed.");
            //      reload_views.begin ();
            //  });

            signals.database_connected.connect (() => {
                debug ("Handle database_connected.");
                reload_schema.begin ();
            });

            schema_dropdown.notify["selected"].connect (schema_changed);

            //  signals.table_activated.connect (() => {
            //      debug ("handle table_activated");

            //      stack.set_visible_child_name (Views.TABLE_DATA);
            //  });

            //  signals.view_activated.connect (() => {
            //      debug ("handle table_activated");

            //      stack.set_visible_child_name (Views.TABLE_DATA);
            //  });
        }

        [GtkCallback]
        private void table_selected () {
            var row = table_list.get_selected_row ();
            
            if (row == null) {
                debug ("Emit table_selected_changed");
                signals.table_selected_changed ("");
            } else {
                var tbname = current_schema.tablenames[row.get_index ()];
    
                debug ("Emit table_selected_changed");
                signals.table_selected_changed (tbname.string);
            }

        }

        [GtkCallback]
        private void table_activated (Gtk.ListBoxRow row) {

            var cur_schema = schema_dropdown.get_selected_item () as Gtk.StringObject;
            assert_nonnull (cur_schema);


            var tbname = table_names.get_item (row.get_index ()) as Relation.Row;
            debug ("Emit table_activated");
            signals.table_activated (cur_schema.string, tbname[0]);
        }

        [GtkCallback]
        private void view_activated (Gtk.ListBoxRow row) {

            var cur_schema = schema_dropdown.get_selected_item () as Gtk.StringObject;
            assert_nonnull (cur_schema);


            var vname = views_names.get_item (row.get_index ()) as Relation.Row;
            debug ("Emit view_activated");
            signals.view_activated (cur_schema.string, vname[0]);
        }

        [GtkCallback]
        private void on_reload_clicked () {
            reload_schema.begin ();
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
        private void on_view_search (Gtk.SearchEntry entry) {
            debug ("Search views: %s", entry.text);
            viewslist_model.get_filter ().changed (Gtk.FilterChange.DIFFERENT);
        }

        [GtkCallback]
        private void view_selected () {
            debug ("view selected.");
        }

        [GtkCallback]
        private void on_show_search (Gtk.ToggleButton btn) {
            if (btn.active) {
                search_table_entry.grab_focus ();
            }
        }

        [GtkCallback]
        private void on_show_view_search (Gtk.ToggleButton btn) {
            if (btn.active) {
                search_views_entry.grab_focus ();
            }
        }

        [GtkChild]
        private unowned Gtk.ListBox table_list;

        [GtkChild]
        private unowned Gtk.SearchEntry search_table_entry;

        [GtkChild]
        private unowned Gtk.ListBox views_list;

        [GtkChild]
        private unowned Gtk.SearchEntry search_views_entry;

        [GtkChild]
        private unowned Gtk.DropDown schema_dropdown;

        [GtkChild]
        private unowned Adw.ViewStack stack;
    }
}