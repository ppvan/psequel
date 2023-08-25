namespace Psequel {
    public class Query : Object, Json.Serializable {
        public string sql { get; construct; }
        public Variant[] params {get; private set;}
        public Query (string sql) {
            Object (sql: sql);
        }

        public Query.with_params (string sql, Variant[] params) {
            Object (sql: sql);
            this.params = params;
        }

        public Query clone () {
            return (Query)Json.gobject_deserialize (typeof (Query), Json.gobject_serialize (this));
        }
    }
}