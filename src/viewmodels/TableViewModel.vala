namespace Psequel {
    public class TableViewModel : BaseViewModel, Observer {

        public Schema schema { get; set; }
        public ObservableList<Table> tables { get; set; default = new ObservableList<Table> (); }
        public Table? selected_table { get; set; }

        public TableDataViewModel tabledata_viewmodel { get; set; }
        public TableStructureViewModel tablestructure_viewmodel {get; set;}


        public SQLService sql_service {get; construct;}

        public TableViewModel (SQLService sql_service) {
            Object (sql_service: sql_service);
            //  tables.append_all (schema.tables);
            //  debug ("table view model created");
            //  debug ("tables: %d", tables.size);

            //  this.notify["current-table"].connect (() => {
            //      debug ("current table changed to " + current_table?.name);
            //      tablestructure_viewmodel = new TableStructureViewModel (current_table);
            //      tabledata_viewmodel = new TableDataViewModel (current_table, sql_service);
            //  });
        }
        public void update (GLib.Object data) {
            debug ("type: %s", data.get_type ().name ());
            schema = (Schema) data;
            tables.clear ();
            load_tables.begin (schema);
        }

        public void select_table (Table table) {
            debug ("selecting table %s", table.name);
            selected_table = table;
        }

        public void select_index (int index) {
            debug ("selecting table %s", tables[index].name);
            selected_table = tables[index];
        }


        private async void load_tables (Schema schema) throws PsequelError {
            debug ("loading tables");
            var query = new Query.with_params (TABLE_LIST, { schema.name });
            var relation = yield sql_service.exec_query_params (query);

            foreach (var item in relation) {
                var table = new Table (schema);
                table.name = item[0];
                tables.append (table);
            }

            debug ("%d tables loaded", tables.size);
        }

        public const string TABLE_LIST = """
        SELECT tablename FROM pg_tables WHERE schemaname=$1;
        """;
    }
}