namespace Psequel {
    public class ViewStructureViewModel : Object {
        public View selected_view { get; set; }

        public ObservableList<Column> columns { get; set; default = new ObservableList<Column> (); }
        public ObservableList<Index> indexes { get; set; default = new ObservableList<Index> (); }

        public ViewStructureViewModel (View view) {
            Object ();

            this.notify["selected-view"].connect (() => {
                load_data ();
            });

            selected_view = view;
        }

        private void load_data () {
            columns.clear ();
            indexes.clear ();

            columns.append_all (selected_view.columns);
            indexes.append_all (selected_view.indexes);
        }
    }
}