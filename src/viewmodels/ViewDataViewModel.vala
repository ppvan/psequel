namespace Psequel {
    public class ViewDataViewModel : Object {
        public View? selected_view { get; set; }
        // public View? current_view {get; set;}

        public bool has_pre_page { get; private set; }
        public bool has_next_page { get; private set; }
        public int current_page { get; set; }

        public string row_ranges {get; private set; default = "";}

        public bool is_loading { get; set; }
        public PsequelError err { get; set; }

        public Relation current_relation { get; set; }
        public Relation.Row? selected_row { get; set; }

        public SQLService sql_service { get; construct; }



        public ViewDataViewModel (View view, SQLService service) {
            Object (sql_service: service);

            this.notify["selected-view"].connect (() => {
                current_page = 0;
                reload_data.begin ();
            });

            this.notify["current-page"].connect (() => {
                if (current_page > 0) {
                    has_pre_page = true;
                } else {
                    has_pre_page = false;
                }
            });

            this.notify["current-relation"].connect (() => {

                int offset = sql_service.query_limit * current_page;
                row_ranges = @"Rows $(1 + offset) - $(offset + current_relation.rows)";


                if (current_relation.rows < sql_service.query_limit) {
                    has_next_page = false;

                } else {
                    has_next_page = true;
                }
            });

            selected_view = view;
        }

        public async void reload_data () {
            yield load_data (selected_view, current_page);
        }

        public async void next_page () {
            current_page = current_page + 1;
            yield load_data (selected_view, current_page);
        }

        public async void pre_page () {
            current_page = current_page - 1;
            yield load_data (selected_view, current_page);
        }

        private inline async void load_data (View view, int page) {

            try {
                is_loading = true;
                current_relation = yield sql_service.select_v2 (view, page);

                is_loading = false;
                debug ("Rows: %d", current_relation.rows);
            } catch (PsequelError err) {
                this.err = err;
            }
        }
    }
}