using Gee;

namespace Psequel {

    public delegate void Job ();

    /* Model specialize for storeing query result. */
    public class BinddingArray: ListModel, Object {
        private Array<string> _data;

        public BinddingArray (int capacity) {
            _data = new Array<string>.sized (true, false, sizeof (string), capacity);
        }

        public GLib.Object? get_item (uint position) {
            return (GLib.Object)_data.index (position);
        }

        public GLib.Type get_item_type () {
            return Type.STRING;
        }

        public uint get_n_items () {
            return _data.length;
        }
    }

    public class ObservableArrayList<T>: ListModel, Object {

        private ArrayList<T> _data;

        public int size { get { return _data.size; } }

        public ObservableArrayList () {
            _data = new ArrayList<T> ();
        }

        public GLib.Object? get_item (uint position) {
            return get_object (position);
        }

        public GLib.Type get_item_type () {
            return _data.element_type;
        }

        public uint get_n_items () {
            return _data.size;
        }

        public GLib.Object? get_object (uint position) {
            int index = (int) position;
            if (index >= _data.size) {
                return null;
            }

            return (Object) _data.get (index);
        }

        public void add (T item) {
            _data.add (item);
            items_changed (size - 1, 0, 1);
        }

        public void remove_at (int index) {
            _data.remove_at (index);
            items_changed (index, 1, 0);
        }

        public void clear () {
            var back_up = this.size;
            _data.clear ();
            items_changed (0, back_up, 0);
        }

        public Iterator<T> iterator () {
            return _data.iterator ();
        }
    }

    public class Worker {
        public string thread_name { private set; get; }
        public Job task;

        public Worker (string name, owned Job task) {
            this.thread_name = name;
            this.task = (owned)task;
        }
    }

    public errordomain PsequelError {
        CONNECTION_ERROR,
        QUERY_FAIL
    }

    /**
    * Util class to mesure execution time than log it using debug()
     */
    public class TimePerf {
        private static int64 _start;
        private static int64 _end;

        public static void begin () {
            _start = GLib.get_real_time ();
        }
        public static void end () {
            _end = GLib.get_real_time ();

            debug (@"Elapsed: %$(int64.FORMAT) ms", (_end - _start) / 1000);
        }

    }

    public void set_up_logging () {
        Log.set_handler (Config.G_LOG_DOMAIN, LogLevelFlags.LEVEL_DEBUG | LogLevelFlags.LEVEL_WARNING, log_function);
    }

    private void log_function (string? domain, LogLevelFlags level, string message) {
        switch (level) {
        case LogLevelFlags.LEVEL_DEBUG:
            print ("[DEBUG] %s\n", message);
            break;
        case LogLevelFlags.LEVEL_WARNING:
            print ("[WARN] %s\n", message);
            break;

        default:
            assert_not_reached ();
        }
    }
}