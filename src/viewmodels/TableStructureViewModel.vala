namespace Psequel {
    public class TableStructureViewModel : Observer, Object {

        public SQLService sql_service { get; set; }
        public Table selected_table { get; set; }

        public ObservableList<Column> columns { get; set; default = new ObservableList<Column> (); }
        public ObservableList<Index> indexes { get; set; default = new ObservableList<Index> (); }
        public ObservableList<ForeignKey> foreign_keys { get; set; default = new ObservableList<ForeignKey> (); }


        public TableStructureViewModel (SQLService sql_service) {
            base ();
            //  debug ("TableStructureViewModel created ");
            this.sql_service = sql_service;

            //  selected_table = table;
        }

        public void update (Event event) {
            switch (event.type) {
                case Event.SCHEMA_CHANGED:
                    var schema = event.data as Schema;
                    load_data.begin (schema);
                    break;
                case Event.SELECTED_TABLE_CHANGED:
                    var table = event.data as Table;
                    selected_table = table;
                    break;
                default:
                    break;
            }
        }

        private async void load_data (Schema schema) {
            columns.clear ();
            indexes.clear ();
            foreign_keys.clear ();

            columns.append_all (yield _get_columns (schema));
            indexes.append_all (yield _get_indexes (schema));
            foreign_keys.append_all (yield _get_fks (schema));

            debug ("cols: %d indx: %d fks: %d", columns.size, indexes.size, foreign_keys.size);
        }

        private async List<Column> _get_columns (Schema schema) {

            var list = new List<Column> ();

            try {
                var query = new Query.with_params (COLUMN_SQL, { schema.name });
                var relation = yield sql_service.exec_query_params (query);

                foreach (var row in relation) {
                    var col = new Column ();
                    col.schemaname = schema.name;
                    col.name = row[0];
                    col.table = row[1];
                    col.column_type = row[2];
                    col.nullable = row[3] == "YES" ? true : false;
                    col.default_val = row[4];

                    list.append (col);
                }
            } catch (PsequelError err) {
                debug (err.message);
            }

            return list;
        }

        private async List<Index> _get_indexes (Schema schema) {

            var list = new List<Index> ();

            try {
                var query = new Query.with_params (INDEX_SQL, { schema.name });
                var relation = yield sql_service.exec_query_params (query);

                foreach (var row in relation) {
                    var index = new Index ();
                    index.schemaname = schema.name;
                    index.name = row[0];
                    index.table = row[1];
                    index.size = row[2];
                    index.indexdef = row[3];

                    list.append (index);
                }
            } catch (PsequelError err) {
                debug (err.message);
            }

            return list;
        }

        private async List<ForeignKey> _get_fks (Schema schema) {

            var list = new List<ForeignKey> ();

            try {
                var query = new Query.with_params (FK_SQL, { schema.name });
                var relation = yield sql_service.exec_query_params (query);

                foreach (var row in relation) {
                    var fk = new ForeignKey ();
                    fk.schemaname = schema.name;
                    fk.name = row[0];
                    fk.table = row[1];
                    fk.fk_def = row[2];

                    list.append (fk);
                }
            } catch (PsequelError err) {
                debug (err.message);
            }

            return list;
        }

        public const string COLUMN_SQL = """
        SELECT column_name, table_name,
        case 
            when domain_name is not null then domain_name
            when data_type='character varying' THEN 'varchar('||character_maximum_length||')'
            when data_type='numeric' THEN 'numeric('||numeric_precision||','||numeric_scale||')'
            else data_type
        end as data_type,
        is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = $1;
        """;
        public const string INDEX_SQL = """
        SELECT indexname, tablename, pg_size_pretty(pg_relation_size(indexname::regclass)) as size, indexdef
        FROM pg_indexes
        WHERE schemaname = $1;
        """;
        public const string FK_SQL = """
        SELECT con.conname, rel.relname, pg_catalog.pg_get_constraintdef(con.oid, true) as condef
        FROM pg_catalog.pg_constraint con
             INNER JOIN pg_catalog.pg_class rel
                        ON rel.oid = con.conrelid
             INNER JOIN pg_catalog.pg_namespace nsp
                        ON nsp.oid = connamespace
        WHERE con.contype = 'f' AND nsp.nspname = $1;
        """;
    }
}