namespace Psequel {
    public class QueryViewModel : BaseViewModel {

        public ObservableList<Query> queries { get; set; default = new ObservableList<Query> ();}
        public Query? current_query { get; set; }

        public string query_string {get; set;}

        // SQL related result.
        public bool is_loading { get; private set; }
        public PsequelError err { get; private set; }

        public Relation current_relation { get; private set; }
        public Relation.Row? selected_row { get; set; }

        //  Status properties
        public string row_affected {get; private set;}
        public string query_time {get; private set;}

        public SQLService sql_service { get; construct; }

        public QueryViewModel (SQLService sql_service) {
            Object (sql_service: sql_service);

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

        public async void run_current_query () {
            var query = new Query (query_string);

            //  if (query.sql != queries.last ().sql) {
            //      queries.append (query);
            //  }

            yield run_query (query);
        }

        private inline async void run_query (Query query) {

            try {
                is_loading = true;
                int64 execute_time;

                current_relation = yield sql_service.exec_query (query.sql, out execute_time);

                is_loading = false;
                debug ("Rows: %d", current_relation.rows);
            } catch (PsequelError err) {
                this.err = err;
            }
        }
    }
}