namespace Psequel {
public class TableDataViewModel : BaseViewModel {
    public const int MAX_FETCHED_ROW = 50;

    public Table ?selected_table { get; set; }
    // public View? current_view {get; set;}

    public bool has_pre_page { get; private set; default = false; }
    public bool has_next_page { get; private set; default = true; }
    public int current_page { get; set; }

    public string row_ranges { get; private set; default = ""; }

    public bool is_loading { get; set; }
    public string err_msg { get; set; }

    public Relation current_relation { get; set; }
    public Relation.Row ?selected_row { get; set; }

    public SQLService sql_service { get; construct; }



    public TableDataViewModel(SQLService service) {
        Object(sql_service: service);

        this.notify["current-page"].connect(() => {
                if (current_page > 0)
                {
                    has_pre_page = true;
                }
                else
                {
                    has_pre_page = false;
                }
            });

        this.notify["current-relation"].connect(() => {
                int offset = MAX_FETCHED_ROW * current_page;
                row_ranges = @"Rows $(1 + offset) - $(offset + current_relation.rows)";

                if (current_relation.rows < MAX_FETCHED_ROW)
                {
                    has_next_page = false;
                }
                else
                {
                    has_next_page = true;
                }
            });


        this.notify["selected-table"].connect(() => {
                current_page = 0;
                reload_data.begin();
            });

        EventBus.instance().selected_table_changed.connect((table) => {
            selected_table = table;
        });
    }

    public async void reload_data() {
        yield load_data(selected_table, current_page);
    }

    public async void next_page() {
        current_page = current_page + 1;
        yield load_data(selected_table, current_page);
    }

    public async void pre_page() {
        current_page = current_page - 1;
        yield load_data(selected_table, current_page);
    }

    private inline async void load_data(Table table, int page) {
        try {
            is_loading       = true;
            current_relation = yield sql_service.select(table, page, MAX_FETCHED_ROW);

            is_loading = false;
            debug("Rows: %d", current_relation.rows);
        } catch (PsequelError err) {
            this.err_msg = err.message;
        }
    }
}
}
