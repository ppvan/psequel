namespace Psequel {
    public class QueryHistoryViewModel : BaseViewModel {
        const string AUTO_EXEC_HISTORY = "auto-exec-history";

        public QueryRepository query_repository {get; private set;}
        public ObservableList<Query> query_history { get; set; default = new ObservableList<Query> (); }
        public Query? selected_query { get; set; }

        // SQL related result.
        public bool is_loading { get; private set; }
        public string err_msg { get; private set; }

        public Relation current_relation { get; private set; }
        public Relation.Row? selected_row { get; set; }

        // Status properties
        public string row_affected { get; private set; }
        public string query_time { get; private set; }

        public SQLService sql_service { get; construct; }


        public QueryHistoryViewModel (SQLService sql_service) {
            Object (sql_service: sql_service);
            query_repository = new QueryRepository (Application.settings);

            this.notify["current-relation"].connect (() => {
                row_affected = @"Row Affected: $(current_relation.row_affected)";

                if (current_relation.fetch_time / SECOND_TO_MS > 0) {
                    if (current_relation.fetch_time / SECOND_TO_MS / MILISECS_TO_US > 0) {
                        query_time = @"Exec time: $(current_relation.fetch_time / SECOND_TO_MS / MILISECS_TO_US) s";
                    } else {
                        query_time = @"Exec time: $(current_relation.fetch_time / SECOND_TO_MS) ms";
                    }
                } else {
                    query_time = @"Exec time: $(current_relation.fetch_time) μs";
                }
            });
        }

        public async void exec_query (Query query) {
            yield run_query_internal (query);

            query_history.prepend (query);
            selected_query = query;
        }

        public async void exec_history (Query query) {
            if (Application.settings.get_boolean (AUTO_EXEC_HISTORY)) {
                yield run_query_internal (query);
            }

            query_history.remove (query);
            query_history.prepend (query);
            selected_query = query;
        }

        private inline async bool run_query_internal (Query query) {
            is_loading = true;

            try {
                current_relation = yield sql_service.exec_query_v2 (query);

                debug ("Rows: %d", current_relation.rows);
                is_loading = false;

                return true;
            } catch (PsequelError err) {
                this.err_msg = err.message;
            }

            is_loading = false;
            return false;
        }
    }
}