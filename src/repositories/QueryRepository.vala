namespace Psequel {
    public class QueryRepository : Object {

        const string KEY = "queries";

        private Settings settings;
        private List<Query> _data;

        public QueryRepository (Settings settings) {
            base ();
            this.settings = settings;
            this._data = deserialize_queries (settings.get_string (KEY));
        }

        public unowned List<Query> get_queries () {
            return this._data;
        }

        public void append_query (Query query) {
            _data.append (query);

            save ();
        }

        public void update_query (Query query) {
            assert_not_reached ();
        }

        public void remove_query (Query query) {
            _data.remove (query);
        }

        public void append_all (List<Query> items) {
            items.foreach ((item) => append_query (item));
        }

        private void save () {
            string json_data = serialize_queries (this._data);
            //  _data.foreach ((item) => debug ("%s", item.sql));
            settings.set_string (KEY, json_data);
        }

        public void clear () {
            _data = new List<Query> ();
            save ();
        }

        private List<Query> deserialize_queries (string json_data) {
            var parser = new Json.Parser ();
            var recent_queries = new List<Query> ();

            try {
                parser.load_from_data (json_data);
                var root = parser.get_root ();
                var queries = root.get_array ();

                queries.foreach_element ((array, index, node) => {
                    var query = (Query) Json.gobject_deserialize (typeof (Query), node);
                    recent_queries.append (query);
                });
            } catch (Error err) {
                debug (err.message);
            }

            return (owned) recent_queries;
        }

        private string serialize_queries (List<Query> queries) {

            var builder = new Json.Builder ();
            builder.begin_array ();

            foreach (var query in queries) {
                builder.add_value (Json.gobject_serialize (query));
            }

            builder.end_array ();

            var node = builder.get_root ();
            return Json.to_string (node, true);
        }
    }
}