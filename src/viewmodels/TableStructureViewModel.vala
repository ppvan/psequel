namespace Psequel {
public class TableStructureViewModel : Observer, Object {
    public SQLService sql_service { get; set; }
    public Table selected_table { get; set; }
    public Schema current_schema { get; set; }

    public ObservableList <Column> columns { get; set; default = new ObservableList <Column> (); }
    public ObservableList <Index> indexes { get; set; default = new ObservableList <Index> (); }
    public ObservableList <ForeignKey> foreign_keys { get; set; default = new ObservableList <ForeignKey> (); }
    public ObservableList <PrimaryKey> primary_keys { get; set; default = new ObservableList <PrimaryKey> (); }


    public TableStructureViewModel(SQLService sql_service) {
        base();
        //  debug ("TableStructureViewModel created ");
        this.sql_service = sql_service;

        //  selected_table = table;
    }

    public void update(Event event) {
        switch (event.type)
        {
        case Event.SCHEMA_CHANGED:
            var schema = event.data as Schema;
            this.current_schema = schema;
            //  load_data.begin();
            break;

        case Event.SELECTED_TABLE_CHANGED:
            var table = event.data as Table;
            load_data.begin((obj, res) => {
                load_data.end(res);
                selected_table = table;
            });
            break;

        default:
            break;
        }
    }

    private async void load_data() {
        columns.clear();
        indexes.clear();
        foreign_keys.clear();
        primary_keys.clear();

        columns.append_all(yield _get_columns(this.current_schema));
        indexes.append_all(yield _get_indexes(this.current_schema));
        foreign_keys.append_all(yield _get_fks(this.current_schema));
        primary_keys.append_all(yield _get_pks(this.current_schema));

        debug("cols: %d indx: %d fks: %d", columns.size, indexes.size, foreign_keys.size);
    }

    private async List <Column> _get_columns(Schema schema) {
        var list = new List <Column> ();

        try {
            var query    = new Query.with_params(COLUMN_SQL, { schema.name });
            var relation = yield sql_service.exec_query_params(query);

            foreach (var row in relation)
            {
                var col = new Column();
                col.schemaname  = schema.name;
                col.name        = row[0];
                col.table       = row[1];
                col.column_type = row[2];
                col.nullable    = row[3] == "YES" ? true : false;
                col.default_val = row[4];

                list.append(col);
            }
        } catch (PsequelError err) {
            debug(err.message);
        }

        return(list);
    }

    private async List <Index> _get_indexes(Schema schema) {
        var list = new List <Index> ();

        try {
            var query    = new Query.with_params(INDEX_SQL, { schema.name });
            var relation = yield sql_service.exec_query_params(query);

            foreach (var row in relation)
            {
                var index = new Index();
                index.schemaname = schema.name;
                index.name       = row[0];
                index.table      = row[1];
                index.size       = row[2];
                index.indexdef   = row[3];

                list.append(index);
            }
        } catch (PsequelError err) {
            debug(err.message);
        }

        return(list);
    }

    private async List <ForeignKey> _get_fks(Schema schema) {
        var list = new List <ForeignKey> ();

        try {
            var query    = new Query(FK_SQL2);
            var relation = yield sql_service.exec_query(query);

            foreach (var row in relation)
            {
                var fk = new ForeignKey();
                fk.schemaname = schema.name;
                fk.name       = row[0];
                fk.table      = row[1];
                fk.fk_table   = row[3];

                fk.columns_v2    = parse_array_result(row[2]);
                fk.fk_columns_v2 = parse_array_result(row[4]);

                list.append(fk);
            }
        } catch (PsequelError err) {
            debug(err.message);
        }

        return(list);
    }

    private async List <PrimaryKey> _get_pks(Schema schema) {
        var list = new List <PrimaryKey> ();

        try {
            var query    = new Query.with_params(PK_SQL, { schema.name });
            var relation = yield sql_service.exec_query_params(query);

            foreach (var row in relation)
            {
                var pk = new PrimaryKey();
                pk.schemaname = schema.name;
                pk.name       = row[0];
                pk.table      = row[1];
                pk.columns    = parse_array_result(row[2]);

                list.append(pk);
            }
        } catch (PsequelError err) {
            debug(err.message);
        }

        return(list);
    }

    private string[] parse_array_result(string array_str) {
        int    len     = array_str.length - 2;
        string content = array_str.substring(1, len);
        return(Csv.parse_row(content));
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
    public const string INDEX_SQL  = """
        SELECT indexname, tablename, pg_size_pretty(pg_relation_size(indexname::regclass)) as size, indexdef
        FROM pg_indexes
        WHERE schemaname = $1;
        """;
    public const string FK_SQL     = """
        SELECT con.conname, rel.relname, pg_catalog.pg_get_constraintdef(con.oid, true) as condef
        FROM pg_catalog.pg_constraint con
             INNER JOIN pg_catalog.pg_class rel
                        ON rel.oid = con.conrelid
             INNER JOIN pg_catalog.pg_namespace nsp
                        ON nsp.oid = connamespace
        WHERE con.contype = 'f' AND nsp.nspname = $1;
        """;

    public const string PK_SQL = """
    SELECT 
        con.conname,
        cls1.relname AS table,
        ARRAY_AGG(attr1.attname) AS columns
    FROM pg_catalog.pg_constraint con
    JOIN pg_catalog.pg_class cls1 ON con.conrelid = cls1.oid
    JOIN pg_catalog.pg_attribute attr1 ON attr1.attrelid = cls1.oid
    JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace 
    WHERE con.contype = 'p'
        AND attr1.attnum = ANY(con.conkey)
        AND nsp.nspname = $1
    GROUP BY con.oid, cls1.relname;
    """;

    public const string FK_SQL2 = """
    SELECT 
        con.conname,
        cls1.relname AS src_table,
        ARRAY_AGG(attr1.attname) AS src_columns,
        cls2.relname AS dest_table,
        ARRAY_AGG(attr2.attname) AS dest_columns
    FROM pg_catalog.pg_constraint con
    JOIN pg_catalog.pg_class cls1 ON con.conrelid = cls1.oid
    JOIN pg_catalog.pg_class cls2 ON con.confrelid = cls2.oid
    JOIN pg_catalog.pg_attribute attr1 ON attr1.attrelid = cls1.oid
    JOIN pg_catalog.pg_attribute attr2 ON attr2.attrelid = cls2.oid
    WHERE con.contype = 'f'
        AND con.confrelid > 0
        AND attr1.attnum = ANY(con.conkey)
        AND attr2.attnum = ANY(con.confkey)
    GROUP BY con.oid, cls1.relname, cls2.relname
    """;
}
}
