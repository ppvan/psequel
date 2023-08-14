namespace Psequel {
    public class QueryViewModel : BaseViewModel {

        public QueryHistoryViewModel query_history_viewmodel { get; set; }

        public ObservableList<Query> queries { get; set; }
        public Query? selected_query { get; set; }


        public SQLService sql_service { get; construct; }

        public QueryViewModel (SQLService sql_service) {
            Object (sql_service: sql_service);
            query_history_viewmodel = new QueryHistoryViewModel (sql_service);
        }

        public async void run_selected_query () {
            if (selected_query == null || selected_query.sql == "") {
                return;
            }

            yield query_history_viewmodel.exec_query (selected_query);
        }

        public async void run_query (Query query) {
            yield query_history_viewmodel.exec_query (query);
        }


        public void selected_query_changed (string text) {
            Query query = new Query (text);
            selected_query = query;
        }
    }
}