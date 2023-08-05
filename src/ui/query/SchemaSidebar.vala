namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/schema-sidebar.ui")]
    public class SchemaSidebar : Gtk.Box {
        public ObservableList<Schema> schemas { get; set; }
        public Schema? current_schema { get; set; }

        public ObservableList<Table> tables {get; set;}
        public Table? selected_table {get; set;}

        public ObservableList<View> views {get; set;}
        public View? selected_view {get; set;}


        public signal void request_load_schema (Schema current_schema);

        public SchemaSidebar () {
            Object ();
        }

        construct {
            
            dropdown.bind_property ("selected", this, "current-schema", DEFAULT, (_, from, ref to) => {
                uint pos = from.get_uint ();
                if (pos != Gtk.INVALID_LIST_POSITION) {
                    to.set_object (schemas.get_item (pos));
                }
            });
            
            this.notify["current-schema"].connect (() => {
                request_load_schema (current_schema);
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
    }
}