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


        [GtkChild]
        private unowned Gtk.Paned paned;
    }
}