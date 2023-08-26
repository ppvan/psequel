namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/schema-view.ui")]
    public class SchemaView : Adw.Bin {
        public SchemaViewModel schema_viewmodel { get; set; }


        public signal void request_logout ();

        public SchemaView () {
            Object ();
        }

        construct {
            setup_paned (paned);
            var container = Window.temp;
            schema_viewmodel = container.find_type (typeof (SchemaViewModel)) as SchemaViewModel;
        }


        [GtkCallback]
        public void request_load_schema (Schema? schema) {
            if (schema == null) {
                debug ("schema is null");
                return ;
            }

            schema_viewmodel.load_schema.begin (schema);
        }

        [GtkCallback]
        public void request_logout_cb () {
            request_logout ();
        }

        [GtkCallback]
        public void table_selected_changed (Table table) {
            debug ("table selected changed");


            schema_viewmodel.table_viewmodel.selected_table = table;
        }

        [GtkCallback]
        public void view_selected_changed (View view) {
            schema_viewmodel.view_viewmodel.current_view = view;
        }


        [GtkChild]
        private unowned Gtk.Paned paned;
    }
}