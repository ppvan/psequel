namespace Psequel {
public class TableViewModel : BaseViewModel, Observer {
    public Schema schema { get; set; }
    public ObservableList <Table> tables { get; set; default = new ObservableList <Table> (); }
    public Table ?selected_table { get; set; }


    public SQLService sql_service { get; private set; }

    //  public signal void table_changed (Table table);

    public TableViewModel(SQLService sql_service) {
        base();
        this.sql_service = sql_service;
        this.notify["selected-table"].connect(() => {
                this.emit_event(Event.SELECTED_TABLE_CHANGED, selected_table);
            });
    }

    public void update(Event event) {
        if (event.type == Event.SCHEMA_CHANGED)
        {
            schema = (Schema)event.data;
            tables.clear();
            load_tables.begin(schema);
        }
    }

    public void select_table(Table ?table) {
        if (table == null)
        {
            return;
        }
        debug("selecting table %s", table.name);
        selected_table = table;
    }

    public void select_index(int index) {
        if (tables[index] == null)
        {
            return;
        }
        debug("selecting table %s", tables[index].name);
        selected_table = tables[index];
    }

    private async void load_tables(Schema schema) throws PsequelError {
        debug("loading tables");
        var query    = new Query.with_params(TABLE_LIST, { schema.name });
        var relation = yield sql_service.exec_query_params(query);

        foreach (var item in relation)
        {
            var table = new Table(schema);
            table.name = item[0];
            tables.append(table);
        }

        debug("%d tables loaded", tables.size);
    }

    public const string TABLE_LIST = """
        SELECT tablename FROM pg_tables WHERE schemaname=$1;
        """;
}
}
