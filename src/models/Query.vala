namespace Psequel {
    public class Query : Object, Json.Serializable {
        public string sql { get; construct; }
        public Query (string sql) {
            Object (sql: sql);
        }

        public Query clone () {
            return (Query)Json.gobject_deserialize (typeof (Query), Json.gobject_serialize (this));
        }
    }
}