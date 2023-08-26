namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/schema-sidebar.ui")]
    public class SchemaSidebar : Gtk.Box {
        public ObservableList<Schema> schemas { get; set; }
        public Schema? current_schema { get; set; }

        public TableViewModel table_viewmodel {get; set;}
        public ObservableList<Table> tables {get; set;}
        public Table? selected_table {get; set;}

        public ObservableList<View> views {get; set;}
        public View? selected_view {get; set;}

        public string view_mode {get; set;}

        public signal void request_load_schema (Schema current_schema);
        public signal void request_logout ();
        public signal void table_selected_changed (Table table);
        public signal void view_selected_changed (View view);

        public SchemaSidebar () {
            Object ();
        }

        construct {
            this.table_viewmodel = (TableViewModel)Window.temp.find_type (typeof (TableViewModel));

            this.notify["selected-view"].connect (() => {
                debug ("selected view changed");
                view_selected_changed (selected_view);
            });
            
            this.notify["current-schema"].connect (() => {
                debug ("current schema changed");
                request_load_schema (current_schema);
            });

            sql_views.bind_property ("visible-child-name", this, "view-mode", DEFAULT);

            dropdown.notify["selected"].connect (() => {
                debug ("selected schema changed");
                current_schema = (Schema)schemas.get_item (dropdown.selected);
            });
            table_selection.notify["selected"].connect (() => {
                table_viewmodel.select_index ((int)table_selection.selected);
            });
            view_selection.notify["selected"].connect (() => {
                selected_view = (View)views.get_item (view_selection.selected);
            });

            dropdown.expression = new Gtk.PropertyExpression (typeof (Schema), null, "name");
            table_filter.expression = new Gtk.PropertyExpression (typeof (Table), null, "name");
            view_filter.expression = new Gtk.PropertyExpression (typeof (View), null, "name");
        }

        [GtkCallback]
        private void on_table_search (Gtk.SearchEntry entry) {
            table_filter.search = entry.text;
        }

        [GtkCallback]
        private void on_view_search (Gtk.SearchEntry entry) {
            view_filter.search = entry.text;
        }

        [GtkCallback]
        private void table_search_reveal () {
            search_table_entry.grab_focus ();
        }

        [GtkCallback]
        private void view_search_reveal () {
            search_views_entry.grab_focus ();
        }

        [GtkCallback]
        private void reload_btn_clicked (Gtk.Button btn) {
            debug ("clicked");

            debug ("current schema: " + current_schema?.name);
            debug ("tables: %d", table_viewmodel.tables.size);
            //  request_load_schema (current_schema);
        }

        [GtkCallback]
        private void logout_btn_clicked (Gtk.Button btn) {
            debug ("clicked");
            request_logout ();
        }

        [GtkChild]
        private unowned Gtk.DropDown dropdown;

        [GtkChild]
        private unowned Gtk.SearchEntry search_table_entry;

        [GtkChild]
        private unowned Gtk.SearchEntry search_views_entry;

        [GtkChild]
        private unowned Gtk.StringFilter table_filter;

        [GtkChild]
        private unowned Gtk.StringFilter view_filter;

        [GtkChild]
        private unowned Gtk.SingleSelection table_selection;

        [GtkChild]
        private unowned Gtk.SingleSelection view_selection;

        [GtkChild]
        private unowned Adw.ViewStack sql_views;
    }
}