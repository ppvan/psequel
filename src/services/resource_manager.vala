namespace Psequel {
    /**
     * Keep and give access to every service in application.
     * Must be initzalize before the UI class.
     */
    public class ResourceManager : Object {


        /**
         * Application specific signals.
         */
        public AppSignals signals;

        /**
         * Recent connections info in last sessions.
         */
        public ObservableArrayList<Connection> recent_connections { get; set; }


        public QueryService query_service { get; set; }

        //  Should not be > 1 because libpq can't create many query in 1 connection. 
        public const int POOL_SIZE = 1;
        public const int MAX_COLUMNS = 50;
        public ThreadPool<Worker> background;

        /**
         * Application setting.
         */
        public Settings settings { get; set; }

        /**
         * List of table in current schema.
         */
        public ObservableArrayList<Relation.Row> table_list;

        /**
         * Application
         */
        public Application app { get; set; }


        private static Once<ResourceManager> _instance;

        public static unowned ResourceManager instance () {
            return _instance.once (() => { return new ResourceManager (); });
        }

        private ResourceManager () {
            Object ();
        }

        public string stringify (bool pretty = true) {
            var root = build_json ();
            return Json.to_string (root, pretty);
        }

        public void save_user_data () {
            settings.set_string ("data", stringify (false));
        }

        /**
         * Load all resource from Gsetting.
         * Because this can't violate singleton, it will init the properties data only.
         */
        public void load_user_data () {
            debug ("Load user setting data");
            // log_structured ("[debug]", LogLevelFlags.LEVEL_DEBUG, "");
            var parser = new Json.Parser ();
            recent_connections = new ObservableArrayList<Connection> ();

            try {
                var buff = settings.get_string ("data");
                parser.load_from_data (buff);
                var root = parser.get_root ();
                var obj = root.get_object ();
                var conns = obj.get_array_member ("recent_connections");

                conns.foreach_element ((array, index, node) => {
                    debug (Json.to_string (node, false));
                    var conn = (Connection) Json.gobject_deserialize (typeof (Connection), node);
                    recent_connections.add (conn);
                });
            } catch (Error err) {
                debug (err.message);
                recent_connections.clear ();
            }

            debug ("User setting loaded");
        }

        private Json.Node build_json () {

            var builder = new Json.Builder ();
            builder.begin_object ();
            builder.set_member_name ("recent_connections");
            builder.begin_array ();

            foreach (var conn in recent_connections) {
                builder.add_value (Json.gobject_serialize (conn));
            }

            builder.end_array ();
            builder.end_object ();

            return builder.get_root ();
        }
    }
}