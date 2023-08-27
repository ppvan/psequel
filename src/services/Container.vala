namespace Psequel {
    public class Container : Object {

        private HashTable<GLib.Type, Object> dependencies;


        /** Manual dependency injection map */
        public Container() {
            Object ();
            dependencies = new HashTable<GLib.Type, Object> (direct_hash, direct_equal);
        }

        public void register (Object obj) {
            var not_found = dependencies.replace (obj.get_type (), obj);

            if (!not_found) {
                warning ("Register type is already in the map");
            }
        }

        public Object find_type (GLib.Type type) {
            if (!dependencies.contains (type)) {
                warning ("Type %s not found in the map", type.name ());
                assert_not_reached ();
            }

            return dependencies.lookup (type);
        }
    }
}