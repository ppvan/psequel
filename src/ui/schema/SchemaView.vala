namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/schema-view.ui")]
    public class SchemaView : Adw.Bin {
        public SchemaViewModel schema_viewmodel { get; set; }


        public signal void request_logout ();

        public SchemaView () {
            Object ();
        }


        [GtkCallback]
        public void request_load_schema (Schema? schema) {
            if (schema == null) {
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
            schema_viewmodel?.table_viewmodel.current_table = table;
        }

        [GtkCallback]
        public void view_selected_changed (View view) {
            schema_viewmodel?.view_viewmodel.current_view = view;
        }
    }
}