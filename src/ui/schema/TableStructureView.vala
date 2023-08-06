namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure-view.ui")]
    public class TableStructureView : Gtk.Box {
        public Table selected_table {get; set;}
        public ObservableList<Column> columns {get; set;}
        public ObservableList<Index> indexes {get; set;}
        public ObservableList<ForeignKey> fks {get; set;}
    }
}