namespace Psequel {
    public class TableViewModel : BaseViewModel {
        public ObservableList<Table> tables { get; set; default = new ObservableList<Table> (); }
        public Table? current_table { get; set; }

        public TableDataViewModel tabledata_viewmodel { get; set; }
        public TableStructureViewModel tablestructure_viewmodel {get; set;}

        public TableViewModel (Schema schema, QueryService query_service) {
            Object ();
            tables.append_all (schema.tables);

            this.notify["current-table"].connect (() => {

                tablestructure_viewmodel = new TableStructureViewModel (current_table);
                //  tablestructure_viewmodel.selected_table = current_table;

                tabledata_viewmodel = new TableDataViewModel (current_table, query_service);
            });
        }
    }
}