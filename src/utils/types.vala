namespace Psequel {
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

        public static int64 uend () {
            _end = GLib.get_real_time ();

            debug (@"Elapsed: %$(int64.FORMAT) μs", (_end - _start));

            return _end - _start;
        }
    }

    public delegate void Job ();

    public class Worker {
        public string thread_name { private set; get; }
        public Job task;

        public Worker (string name, owned Job task) {
            this.thread_name = name;
            this.task = (owned) task;
        }

        public void run () {

            // Thread.usleep ((ulong)1e6);
            this.task ();
        }
    }

    public T autowire<T> () {
        var container = Container.instance ();
        return (T) container.find_type (typeof (T));
    }
}