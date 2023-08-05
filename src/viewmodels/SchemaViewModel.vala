namespace Psequel {
    public class SchemaViewModel : BaseViewModel {

        const string DEFAULT = "public";

        public ObservableList<Schema> schemas { get; set; default = new ObservableList<Schema> (); }
        public Schema? current_schema { get; set; }

        public ObservableList<Table> tables {get; set; default = new ObservableList<Table> ();}
        public ObservableList<View> views {get; set; default = new ObservableList<View> ();}


        public SchemaRepository repository;
        public QueryService query_service { get; construct; }
        public SchemaService schema_service { get; private set; }

        public SchemaViewModel (QueryService service) {
            Object (query_service: service);
        }

        public void connect_db (Connection conn) {
            list_schemas.begin (conn);
        }

        public async void load_schema (Schema schema) {
            yield schema_service.load_schema (schema);
            current_schema = schema;

            tables = schema.tables;
            views = schema.views;
        }

        public async void list_schemas (Connection conn) {
            yield query_service.connect_db (conn);

            schema_service = new SchemaService (query_service);

            var unload_schemas = yield schema_service.get_schemas ();

            schemas.append_all (unload_schemas);
        }


    }
}