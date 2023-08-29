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
            schema_viewmodel = autowire<SchemaViewModel> ();
        }


        [GtkChild]
        private unowned Gtk.Paned paned;
    }
}