

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Gtk.Box {
        public MenuModel menu {get; set;}
        public Table selected_table {get; set;}
        public View selected_view {get; set;}

        public TableViewModel table_viewmodel {get; set;}
        public ViewViewModel view_viewmodel {get; set;}

        /** Whether should show view or table info */
        public string view_mode {get; set;}

    }
}