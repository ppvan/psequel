namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/view-structure-view.ui")]
    public class ViewStructureView : Gtk.Box {
        public ViewStructureViewModel viewstructure_viewmodel {get; set;}


        public ViewStructureView () {
            Object ();
        }
    }
}