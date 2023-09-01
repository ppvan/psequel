
namespace Psequel {

    /** Class process and load {@link Schema} infomation */
    public class SchemaService : Object {

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
        public const string TB_SQL = """
        SELECT tablename FROM pg_tables WHERE schemaname=$1;
        """;
        public const string VIEW_SQL = """
        SELECT table_name FROM INFORMATION_SCHEMA.views WHERE table_schema = $1;
        """;

        public const string SCHEMA_LIST_SQL = """
        SELECT schema_name 
        FROM information_schema.schemata;
        """;
        // WHERE schema_name NOT LIKE 'pg_%' AND schema_name NOT LIKE 'information_schema'

        private SQLService sql_service;

        public SchemaService (SQLService service) {
            this.sql_service = service;
        }

        /* Get the schema list as string */
        public async string[] schema_list () throws PsequelError {

            var query = new Query (SCHEMA_LIST_SQL);
            var relation = yield sql_service.exec_query (query);

            var _schema_list = new string[relation.rows];

            for (int i = 0; i < _schema_list.length; i++) {
                _schema_list[i] = relation[i][0];
            }

            return _schema_list;
        }

        /** Get the schema list.
         *
         * These schemas only contains names.For info about tables, views in schemas, load is with
         * {@link load_schema}
         */
        public async List<Schema> get_schemas () {
            var list = new List<Schema> ();
            try {
                var query = new Query (SCHEMA_LIST_SQL);
                var relation = yield sql_service.exec_query (query);

                for (int i = 0; i < relation.rows; i++) {
                    var s = new Schema (relation[i][0]);
                    list.append (s);
                }
            } catch (PsequelError err) {
                debug (err.message);
            }

            return list;
        }

        /** Load table list, view list into the schema. */
        public async void load_schema (Schema schema) throws PsequelError.QUERY_FAIL {
            //  yield load_tables_and_views (schema);
        }

        //  private async void load_tables_and_views (Schema schema) {

        //      // old table auto clean by GC
        //      schema.tables = new List<Table> ();
        //      schema.views = new List<View> ();

        //      var table_groups = new HashTable<string, Table> (GLib.str_hash, GLib.str_equal);
        //      var view_groups = new HashTable<string, View> (GLib.str_hash, GLib.str_equal);
            
        //      var table_names = yield get_tbnames (schema);
            
        //      var view_names = yield get_viewnames (schema);
            
        //      var columns = yield get_columns (schema);
            
        //      var indexes = yield get_indexes (schema);
            
        //      var fks = yield get_fks (schema);

        //      debug ("cols: %u indx: %u fks: %u", columns.length (), indexes.length (), fks.length ());

        //      table_names.foreach ((tbname) => {
        //          var table = new Table (schema) {
        //              name = tbname,
        //          };
        //          table_groups.insert (tbname, table);
        //      });

        //      view_names.foreach ((tbname) => {
        //          var view = new View (schema) {
        //              name = tbname,
        //          };
        //          view_groups.insert (tbname, view);
        //      });

        //      columns.foreach ((col) => {
        //          if (table_groups.contains (col.table)) {
        //              var table = table_groups.get (col.table);
        //              table.columns.append (col);
        //          }

        //          if (view_groups.contains (col.table)) {
        //              var view = view_groups.get (col.table);
        //              view.columns.append (col);
        //          }
        //      });

        //      indexes.foreach ((index) => {
        //          if (table_groups.contains (index.table)) {
        //              var table = table_groups.get (index.table);
        //              table.indexes.append (index);
        //          }

        //          if (view_groups.contains (index.table)) {
        //              var view = view_groups.get (index.table);
        //              view.indexes.append (index);
        //          }
        //      });

        //      fks.foreach ((fk) => {
        //          if (table_groups.contains (fk.table)) {
        //              var table = table_groups.get (fk.table);
        //              table.foreign_keys.append (fk);
        //          }
        //      });

        //      var tables = table_groups.steal_all_values ();

        //      for (int i = 0; i < tables.length; i++) {
        //          schema.tables.append (tables[i]);
        //      }

        //      var views = view_groups.steal_all_values ();

        //      for (int i = 0; i < views.length; i++) {
        //          schema.views.append (views[i]);
        //      }
        //  }

        private async List<string> get_tbnames (Schema schema) {
            var list = new List<string> ();

            try {
                var query = new Query.with_params (TB_SQL, { schema.name });
                var relation = yield sql_service.exec_query_params (query);

                foreach (var row in relation) {
                    list.append (row[0]);
                }
            } catch (PsequelError err) {
                debug (err.message);
            }

            return list;
        }

        private async List<string> get_viewnames (Schema schema) {
            var list = new List<string> ();

            try {
                var query = new Query.with_params (VIEW_SQL, { schema.name });
                var relation = yield sql_service.exec_query_params (query);

                foreach (var row in relation) {
                    list.append (row[0]);
                }
            } catch (PsequelError err) {
                debug (err.message);
            }

            return list;
        }

        private async List<Column> get_columns (Schema schema) {

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

        private async List<Index> get_indexes (Schema schema) {

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

        private async List<ForeignKey> get_fks (Schema schema) {

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
    }
}