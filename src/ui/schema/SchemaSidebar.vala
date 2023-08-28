namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/schema-sidebar.ui")]
    public class SchemaSidebar : Gtk.Box {


        public NavigationService navigation_service { get; set; }
        public SchemaViewModel schema_viewmodel { get; set; }
        public TableViewModel table_viewmodel {get; set;}
        public ViewViewModel view_viewmodel {get; set;}

        public string view_mode {get; set;}

        public SchemaSidebar () {
            Object ();
        }

        construct {
            this.table_viewmodel = (TableViewModel)Window.temp.find_type (typeof (TableViewModel));
            this.view_viewmodel = (ViewViewModel)Window.temp.find_type (typeof (ViewViewModel));
            this.schema_viewmodel = (SchemaViewModel)Window.temp.find_type (typeof (SchemaViewModel));
            this.navigation_service = (NavigationService)Window.temp.find_type (typeof (NavigationService));

            sql_views.bind_property ("visible-child-name", this, "view-mode", DEFAULT);

            dropdown.notify["selected"].connect (() => {
                schema_viewmodel.select_index ((int)dropdown.selected);
            });
            table_selection.notify["selected"].connect (() => {
                var table = table_model.get_item ((int)table_selection.selected);
                table_viewmodel.select_table ((Table)table);
            });
            view_selection.notify["selected"].connect (() => {
                var view = view_model.get_item ((int)view_selection.selected);
                view_viewmodel.select_view ((View)view);
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
            schema_viewmodel.reload.begin ();
        }

        [GtkCallback]
        private void logout_btn_clicked (Gtk.Button btn) {
            navigation_service.navigate (NavigationService.CONNECTION_VIEW);
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
        private unowned Gtk.FilterListModel table_model;

        [GtkChild]
        private unowned Gtk.FilterListModel view_model;

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