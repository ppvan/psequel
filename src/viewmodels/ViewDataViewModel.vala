namespace Psequel {
public class ViewDataViewModel : Object, Observer {
    public View ?selected_view { get; set; }
    // public View? current_view {get; set;}

    public bool has_pre_page { get; private set; }
    public bool has_next_page { get; private set; }
    public int current_page { get; set; }

    public string row_ranges { get; private set; default = ""; }

    public bool is_loading { get; set; }
    public string err_msg { get; set; }

    public Relation current_relation { get; set; }
    public Relation.Row ?selected_row { get; set; }

    public SQLService sql_service { get; private set; }


    public ViewDataViewModel(SQLService service) {
        base();
        this.sql_service = service;

        this.notify["selected-view"].connect(() => {
                current_page = 0;
                reload_data.begin();
            });

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
                int offset = TableDataViewModel.MAX_FETCHED_ROW * current_page;
                row_ranges = @"Rows $(1 + offset) - $(offset + current_relation.rows)";


                if (current_relation.rows < TableDataViewModel.MAX_FETCHED_ROW)
                {
                    has_next_page = false;
                }
                else
                {
                    has_next_page = true;
                }
            });
    }

    public void update(Event event) {
        switch (event.type)
        {
        case Event.SELECTED_VIEW_CHANGED:
            selected_view = event.data as View;
            break;
        }
    }

    public async void reload_data() {
        yield load_data(selected_view, current_page);
    }

    public async void next_page() {
        current_page = current_page + 1;
        yield load_data(selected_view, current_page);
    }

    public async void pre_page() {
        current_page = current_page - 1;
        yield load_data(selected_view, current_page);
    }

    private inline async void load_data(View view, int page) {
        try {
            is_loading       = true;
            current_relation = yield sql_service.select(view, page, TableDataViewModel.MAX_FETCHED_ROW);

            is_loading = false;
            debug("Rows: %d", current_relation.rows);
        } catch (PsequelError err) {
            this.err_msg = err.message;
        }
    }
}
}
