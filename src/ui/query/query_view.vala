

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {


        public const string TABLE_DATA = "data-view";
        public const string TABLE_STRUCTURE = "structure-view";
        public const string QUERY_EDITOR = "query-editor";

        private unowned QueryService query_service;
        private unowned WindowSignals signals;
        private SchemaService schema_service;

        private ObservableArrayList<Schema> schemas;

        private Schema _current_schema;
        public Schema current_schema {
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

        private Gtk.StringFilter tbname_filter;
        private Gtk.StringFilter vname_filter;


        public QueryView () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            query_service = ResourceManager.instance ().query_service;

            schema_service = new SchemaService (query_service);
            schemas = new ObservableArrayList<Schema> ();

            var exp = new Gtk.PropertyExpression (typeof (Gtk.StringObject), null, "string");
            tbname_filter = new Gtk.StringFilter (exp);
            vname_filter = new Gtk.StringFilter (exp);

            setup_signals ();
            set_up_schema ();
        }


        /**
         * Function update table list when schema changed.
         */
        private void schema_changed () {
            uint index = schema_dropdown.get_selected ();
            current_schema = schemas.get_item (index) as Schema;
        }

        /**
         * Reload schema list to the drop down by fetching database.
         */
        private async void reload_schema () throws PsequelError {

            var schema_list = yield schema_service.schema_list ();

            // Clear last item.

            schema_dropdown.model = null;

            for (int i = 0; i < schema_list.length; i++) {
                var cur_schema = yield schema_service.load_schema (schema_list[i]);

                schemas.add (cur_schema);
            }

            schema_dropdown.model = schemas;
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
            var tablelist_model = new Gtk.FilterListModel (current_schema.tablenames, this.tbname_filter);
            this.table_list.bind_model (tablelist_model, table_row_factory);
        }

        private void bind_views_list () {
            var viewslist_model = new Gtk.FilterListModel (current_schema.viewnames, this.vname_filter);
            this.views_list.bind_model (viewslist_model, view_row_factory);
        }

        private void set_up_schema () {
            // this.schema_model = new Gtk.StringList (null);
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

        private void setup_signals () {
            // signals can only be connected after the window is ready.
            // because widget access window to get signals.
            ResourceManager.instance ().app_signals.window_ready.connect (() => {
                signals = get_parrent_window (this).signals;

                signals.database_connected.connect (() => {
                    debug ("Handle database_connected.");
                    reload_schema.begin ();
                });

                schema_dropdown.notify["selected"].connect (schema_changed);
            });
        }

        [GtkCallback]
        private void table_selected () {
            var row = table_list.get_selected_row ();
            return_if_fail (row != null);
            var tbname = current_schema.tablenames[row.get_index ()];

            debug ("Emit table_selected_changed");

            Idle.add_once (() => {
                stack.visible_child_name = TABLE_DATA;
            });

            signals.table_selected_changed (tbname.string);
        }

        [GtkCallback]
        private void table_activated (Gtk.ListBoxRow row) {

            var tbname = current_schema.tablenames[row.get_index ()];
            debug ("Emit table_activated");
            signals.table_activated (current_schema, tbname.string);
        }

        [GtkCallback]
        private void view_activated (Gtk.ListBoxRow row) {

            var vname = current_schema.viewnames[row.get_index ()];
            debug ("Emit view_activated");
            signals.view_activated (current_schema, vname.string);
        }

        [GtkCallback]
        private void on_reload_clicked () {
            reload_schema.begin ();
        }

        [GtkCallback]
        private void on_logout_clicked () {
            var window = (Window) ResourceManager.instance ().app.get_active_window ();
            window.navigate_to (Views.CONNECTION);
        }

        [GtkCallback]
        private void on_search (Gtk.SearchEntry entry) {
            debug ("Search tables: %s", entry.text);
            this.tbname_filter.search = entry.text;
            // tablelist_model.get_filter ().changed (Gtk.FilterChange.DIFFERENT);
        }

        [GtkCallback]
        private void on_view_search (Gtk.SearchEntry entry) {
            debug ("Search views: %s", entry.text);
            this.vname_filter.search = entry.text;
            // viewslist_model.get_filter ().changed (Gtk.FilterChange.DIFFERENT);
        }

        [GtkCallback]
        private void view_selected () {
            var row = views_list.get_selected_row ();

            var vname = current_schema.viewnames[row.get_index ()];
            debug ("Emit view_selected");
            // Idle.add_once (() => {
            // stack.visible_child_name = TABLE_DATA;
            // });
            signals.view_selected_changed (vname.string);
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