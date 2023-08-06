namespace Psequel {
    public class QueryViewModel : BaseViewModel {

        public QueryService query_service {get; construct;}

        public QueryViewModel (QueryService query_service) {
            Object (query_service: query_service);
        }
    }
}