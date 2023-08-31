namespace Psequel {
    public class Query : Object, Json.Serializable {
        public string sql { get; private set; }
        public Variant[] params;
        public Query (string sql) {
            base();
            this.sql = sql;
        }

        public Query.with_params (string sql, Variant[] params) {
            this(sql);
            this.params = params;
        }

        public void set_limit (int limit) {
            if (!is_select ()) {
                return;
            }
            sql += @" LIMIT $limit";
        }

        public bool is_select () {
            return sql.up (6) == "SELECT";
        }

        public Query clone () {
            return (Query)Json.gobject_deserialize (typeof (Query), Json.gobject_serialize (this));
        }
    }
}