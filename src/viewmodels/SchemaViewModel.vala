namespace Psequel {
    public class SchemaViewModel : BaseViewModel, Observer {

        const string DEFAULT = "public";

        public ObservableList<Schema> schemas { get; set; default = new ObservableList<Schema> (); }
        public Schema? current_schema { get; set; }

        //  Needed to interact with gtk.dropdown properly.
        public int current_index { get; set;}

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

        public void select_index (int index) {

            if (index < 0 || index >= schemas.size) {
                return;
            }
            debug ("Select index %d, %s\n", index, schemas[index].name);
            select_schema.begin (schemas[index]);
        }

        public void update (Event event) {
            if (event.type == Event.ACTIVE_CONNECTION) {
                // delay for ui to play animation
                Timeout.add_once (300, ()  => {
                    database_connected.begin ();
                });
            }
        }

        public async void reload () throws PsequelError {
            if (current_schema == null) {
                return;
            }
            yield select_schema (current_schema);
        }

        private async void database_connected () throws PsequelError {
            // auto load schema list.
            yield list_schemas ();
            
            yield select_schema (schemas.find (s => s.name == DEFAULT));
        }

        /** Select current schema */
        private async void select_schema (Schema schema) throws PsequelError {
            debug ("Select schema: %s", schema.name);
            current_schema = schema;
        }

        /** List schema from database. */
        private async void list_schemas () throws PsequelError {
            var unload_schemas = yield schema_service.schema_list ();

            var public_first_schemas = new List<Schema> ();
            
            foreach(var s in unload_schemas) {
                if (s.name == DEFAULT) {
                    public_first_schemas.insert (s, 0);
                } else {
                    public_first_schemas.append (s);
                }
            }

            schemas.append_all (public_first_schemas);
        }
    }
}