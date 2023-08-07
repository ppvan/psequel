namespace Psequel {
    public class TableStructureViewModel : Object {

        public Table selected_table { get; set; }

        public ObservableList<Column> columns { get; set; default = new ObservableList<Column> (); }
        public ObservableList<Index> indexes { get; set; default = new ObservableList<Index> (); }
        public ObservableList<ForeignKey> foreign_keys { get; set; default = new ObservableList<ForeignKey> (); }


        public TableStructureViewModel (Table table) {
            Object ();

            this.notify["selected-table"].connect (() => {
                load_data ();
            });

            selected_table = table;
        }

        private void load_data () {
            columns.clear ();
            indexes.clear ();
            foreign_keys.clear ();

            columns.append_all (selected_table.columns);
            indexes.append_all (selected_table.indexes);
            foreign_keys.append_all (selected_table.foreign_keys);
        }
    }
}