namespace Psequel {
    public class ViewDataViewModel : Object {
        public View? selected_view { get; set; }
        // public View? current_view {get; set;}

        public bool has_pre_page { get; private set; }
        public bool has_next_page { get; private set; }
        public int current_page { get; set; }

        public bool is_loading { get; set; }
        public PsequelError err { get; set; }

        public Relation current_relation { get; set; }
        public Relation.Row? selected_row { get; set; }

        public QueryService query_service { get; construct; }



        public ViewDataViewModel (View view, QueryService service) {
            Object (query_service: service);

            this.notify["selected-view"].connect (() => {
                current_page = 0;
                reload_data.begin ();
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
                current_relation = yield query_service.select_v2 (view, page);

                is_loading = false;
                debug ("Rows: %d", current_relation.rows);
            } catch (PsequelError err) {
                this.err = err;
            }
        }
    }
}