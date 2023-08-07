namespace Psequel {

    public class TableDataViewModel : BaseViewModel {
        public Table? selected_table { get; set; }
        // public View? current_view {get; set;}

        public bool has_pre_page { get; private set; }
        public bool has_next_page { get; private set; }
        public int current_page { get; set; }

        public bool is_loading { get; set; }
        public PsequelError err { get; set; }

        public Relation current_relation { get; set; }
        public Relation.Row? selected_row { get; set; }

        public SQLService sql_service { get; construct; }



        public TableDataViewModel (Table table, SQLService service) {
            Object (sql_service: service);



            this.notify["selected-table"].connect (() => {
                current_page = 0;
                reload_data.begin ();
            });

            selected_table = table;
        }

        public async void reload_data () {
            yield load_data (selected_table, current_page);
        }

        public async void next_page () {
            current_page = current_page + 1;
            yield load_data (selected_table, current_page);
        }

        public async void pre_page () {
            current_page = current_page - 1;
            yield load_data (selected_table, current_page);
        }

        private inline async void load_data (Table table, int page) {

            try {
                is_loading = true;
                current_relation = yield sql_service.select_v2 (table, page);

                is_loading = false;
                debug ("Rows: %d", current_relation.rows);
            } catch (PsequelError err) {
                this.err = err;
            }
        }
    }
}