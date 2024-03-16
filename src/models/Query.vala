namespace Psequel {
    public class Query : Object, Json.Serializable {

        // Properties must be public, get, set inorder to Json.Serializable works
        public int64 id {get; set; default = 0;}
        public string sql { get; set; }

        public List<string> params {get; owned set; default = new List<string>();}
        public List<uint> param_types { get; owned set; default = new List<uint>();}

        public static Regex DDL_REG = /^(CREATE | DROP | RENAME | ALTER | INSERT | UPDATE | DELETE).*$/i;

        public Query (string sql) {
            base ();
            this.sql = sql;
        }

        public Query.with_params (string sql, string[] params) {
            this(sql);

            for(int i = 0; i < params.length; i++) {
                this.params.append ((owned)params[i]);
            }
        }

        public Query clone () {
            return (Query) Json.gobject_deserialize (typeof (Query), Json.gobject_serialize (this));
        }
    }
}