namespace Psequel {

    /* View here is database view (virtual tables), not UI */
    public class ViewViewModel : BaseViewModel {
        public ObservableList<View> views { get; set; default = new ObservableList<View> (); }
        public View? current_view { get; set; }

        public ObservableList<Column> columns {get; set; default = new ObservableList<Column> (); }
        public ObservableList<Index> indexes {get; set; default = new ObservableList<Index> (); }

        public ViewViewModel (Schema schema) {
            Object ();

            views.append_all (schema.views);

            this.notify["current-view"].connect (() => {
                columns.clear ();
                indexes.clear ();

                columns.append_all (current_view.columns);
                indexes.append_all (current_view.indexes);
            });
        }
    }
}