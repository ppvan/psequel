namespace Psequel {
    public class ConnectionRepository : Object {

        const string KEY = "data";

        /** settings may have many nodes that's have connections data, schema data, etc...
         * {
         * "recent_connections": []
         * "schema": []
         * ....
         *}
         */
        const string NODE_NAME = "recent_connections";


        private Settings settings;
        private List<Connection> _data;

        public ConnectionRepository (Settings settings) {
            base ();
            this.settings = settings;
            this._data = deserialize_connection (settings.get_string (KEY));
        }

        public unowned List<Connection> get_connections () {
            return this._data;
        }

        public void append_connection (Connection connection) {
            _data.append (connection);
        }

        public void update_connection (Connection connection) {
            assert_not_reached ();
        }

        public void remove_connection (Connection connection) {
            _data.remove (connection);
        }

        public async void save () {
            string json_data = serialize_connection (this._data);
            //  _data.foreach ((item) => debug ("%s", item.name));
            settings.set_string (KEY, json_data);
        }

        private List<Connection> deserialize_connection (string json_data) {
            var parser = new Json.Parser ();
            var recent_connections = new List<Connection> ();

            try {
                parser.load_from_data (json_data);
                var root = parser.get_root ();
                var obj = root.get_object ();
                var conns = obj.get_array_member (NODE_NAME);

                conns.foreach_element ((array, index, node) => {
                    var conn = (Connection) Json.gobject_deserialize (typeof (Connection), node);
                    recent_connections.append (conn);
                });
            } catch (Error err) {
                debug (err.message);
            }

            return (owned) recent_connections;
        }

        private string serialize_connection (List<Connection> conns) {

            var builder = new Json.Builder ();
            builder.begin_object ();
            builder.set_member_name (NODE_NAME);
            builder.begin_array ();

            foreach (var conn in conns) {
                builder.add_value (Json.gobject_serialize (conn));
            }

            builder.end_array ();
            builder.end_object ();

            var node = builder.get_root ();
            return Json.to_string (node, true);
        }
    }
}