namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/view-structure-view.ui")]
    public class ViewStructureView : Gtk.Box {
        public View selected_view {get; set;}

        public ObservableList<Column> columns {get; set;}
        public ObservableList<Index> indexes {get; set;}


        public ViewStructureView () {
            Object ();
        }
    }
}