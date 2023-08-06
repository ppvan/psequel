namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-data-view.ui")]
    public class TableDataView : Gtk.Box {

        public TableDataViewModel tabledata_viewmodel {get; set;}

        public TableDataView () {
            Object ();
        }

        [GtkCallback]
        private async void reload_data () {
            yield tabledata_viewmodel.reload_data ();
        }

        [GtkCallback]
        private async void next_page () {
            yield tabledata_viewmodel.next_page ();
        }

        [GtkCallback]
        private async void pre_page () {
            yield tabledata_viewmodel.pre_page ();
        }
    }
}