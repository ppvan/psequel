

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Gtk.Box {
        public MenuModel menu {get; set;}
        public Table selected_table {get; set;}

    }
}