namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure-view.ui")]
    public class TableStructureView : Gtk.Box {
        public TableStructureViewModel tablestructure_viewmodel { get; set; }
    }
}