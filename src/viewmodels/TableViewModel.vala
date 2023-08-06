namespace Psequel {
    public class TableViewModel : BaseViewModel {
        public ObservableList<Table> tables {get; set; default = new ObservableList<Table> ();}
        public Table? current_table {get; set;}

        public ObservableList<Column> columns {get; set;}
        public ObservableList<Index> indexes {get; set;}
        public ObservableList<ForeignKey> foreign_keys {get; set;}


        public TableViewModel (Schema schema) {
            Object ();
            tables.append_all (schema.tables);
        }
    }
}