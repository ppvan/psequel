namespace Psequel {
    public class TableViewModel : BaseViewModel {
        public ObservableList<Table> tables {get; set; default = new ObservableList<Table> ();}
        public Table? current_table {get; set;}


        public TableViewModel (Schema schema) {
            Object ();
            tables = schema.tables;
        }
    }
}