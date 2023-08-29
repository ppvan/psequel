namespace Psequel {
    public class SchemaViewModel : BaseViewModel, Observer {

        const string DEFAULT = "public";

        public ObservableList<Schema> schemas { get; set; default = new ObservableList<Schema> (); }
        public Schema? current_schema { get; set; }

        public SchemaRepository repository;

        // Services

        public SchemaService schema_service { get; private set; }

        public SchemaViewModel (SchemaService service) {
            base();
            this.schema_service = service;
            this.notify["current-schema"].connect (() => {
                this.emit_event (Event.SCHEMA_CHANGED, current_schema);
            });
        }

        public void update (Event event) {
            if (event.type == Event.ACTIVE_CONNECTION) {
                database_connected.begin ();
            }
        }

        public async void database_connected () throws PsequelError {
            // auto load schema list.
            yield list_schemas ();
            yield load_schema (schemas.find (s => s.name == DEFAULT));
        }

        public async void load_schema (Schema schema) throws PsequelError {
            debug ("Loading schema: %s", schema.name);
            yield schema_service.load_schema (schema);

            current_schema = schema;
        }

        public async void reload () throws PsequelError {
            if (current_schema == null) {
                return;
            }
            yield load_schema (current_schema);
        }

        public async void list_schemas () throws PsequelError {
            var unload_schemas = yield schema_service.get_schemas ();

            schemas.append_all (unload_schemas);
        }

        public void select_index (int index) {
            if (index < 0 || index >= schemas.size) {
                return;
            }
            debug ("Selecting schema: %s", schemas[index].name);
            current_schema = schemas[index];
        }
    }
}