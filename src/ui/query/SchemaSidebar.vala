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

        public Gtk.Expression expression { get; set; }

        public SchemaSidebar () {
            Object ();
        }

        construct {
            this.expression = new Gtk.PropertyExpression (typeof (Schema), null, "name");
            dropdown.expression = this.expression;

            dropdown.bind_property ("selected", this, "current-schema", DEFAULT, (_, from, ref to) => {
                uint pos = from.get_uint ();
                if (pos != Gtk.INVALID_LIST_POSITION) {
                    to.set_object (schemas.get_item (pos));
                }
            });

            this.notify["current-schema"].connect (() => {
                request_load_schema (current_schema);
            });
        }


        [GtkChild]
        private unowned Gtk.DropDown dropdown;
    }
}