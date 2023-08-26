namespace Psequel {
    public class SchemaViewModel : BaseViewModel {

        const string DEFAULT = "public";

        public ObservableList<Schema> schemas { get; set; default = new ObservableList<Schema> (); }
        public Schema? current_schema { get; set; }

        // Child viewmodel
        public TableViewModel table_viewmodel { get; set; }
        public ViewViewModel view_viewmodel { get; set; }
        public QueryViewModel query_viewmodel { get; set; }

        public SchemaRepository repository;

        // Services
        public SQLService sql_service { get; private set; }
        public SchemaService schema_service { get; private set; }

        public SchemaViewModel (SQLService service) {
            base();
            this.sql_service = service;
            this.notify["current-schema"].connect (() => {
                debug ("Schema changed");
                this.emit_event ("schema", current_schema);
                //  table_viewmodel = new TableViewModel (current_schema, sql_service);
                view_viewmodel = new ViewViewModel (current_schema, sql_service);
                query_viewmodel = new QueryViewModel (current_schema, sql_service);
            });
        }

        public async void connect_db (Connection conn) throws PsequelError {
            yield sql_service.connect_db (conn);

            // auto load schema list.
            yield list_schemas ();

            yield load_schema (schemas.find (s => s.name == DEFAULT));
        }

        public async void load_schema (Schema schema) throws PsequelError {
            debug ("Loading schema: %s", schema.name);
            yield schema_service.load_schema (schema);

            current_schema = schema;
        }

        public async void list_schemas () throws PsequelError {

            schema_service = new SchemaService (sql_service);

            var unload_schemas = yield schema_service.get_schemas ();

            schemas.append_all (unload_schemas);
        }
    }
}