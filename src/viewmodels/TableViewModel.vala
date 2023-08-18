namespace Psequel {
    public class TableViewModel : BaseViewModel {
        public ObservableList<Table> tables { get; set; default = new ObservableList<Table> (); }
        public Table? current_table { get; set; }

        public TableDataViewModel tabledata_viewmodel { get; set; }
        public TableStructureViewModel tablestructure_viewmodel {get; set;}

        public TableViewModel (Schema schema, SQLService sql_service) {
            Object ();
            tables.append_all (schema.tables);
            debug ("table view model created");
            debug ("tables: %d", tables.size);

            this.notify["current-table"].connect (() => {
                debug ("current table changed to " + current_table?.name);
                tablestructure_viewmodel = new TableStructureViewModel (current_table);
                tabledata_viewmodel = new TableDataViewModel (current_table, sql_service);
            });

        }
    }
}