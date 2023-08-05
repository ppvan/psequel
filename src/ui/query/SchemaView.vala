namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/schema-view.ui")]
    public class SchemaView : Adw.Bin {
        public SchemaViewModel viewmodel { get; set; }


        public ObservableList<Schema> schemas {get; set;}
        public Schema? current_schema {get; set;}

        public SchemaView () {
            Object ();
        }


        [GtkCallback]
        public void request_load_schema (Schema? schema) {
            if (schema == null) {
                return ;
            }

            viewmodel.load_schema.begin (schema);
        }
    }
}