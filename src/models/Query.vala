namespace Psequel {
    public class Query : Object {
        public string sql {get; construct;}

        public Query (string sql) {
            Object (sql: sql);
        }
    }
}