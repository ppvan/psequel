namespace Psequel {

    public Window get_parrent_window (Gtk.Widget widget) {
        var window = widget.get_root ();

        if (window is Gtk.Window) {
            return (Window) window;
        } else {
            warning ("Widget %s root is not a window", widget.name);

            assert_not_reached ();
        }
    }

    /** Why it has to be like this? you ask. Because i don't find a way to limit paned postion that never hide it's child */
    public void setup_paned (Gtk.Paned paned) {

        debug ("Pann");

        paned.notify["position"].connect (() => {
            var start = paned.start_child;
            var end = paned.end_child;

            switch (paned.orientation) {
                case Gtk.Orientation.HORIZONTAL:
                    if (paned.position < start.width_request) {
                        paned.position = start.width_request;
                    } else if (paned.position > paned.get_width () - end.width_request) {
                        paned.position = paned.get_width () - end.width_request;
                    }
                    break;
                case Gtk.Orientation.VERTICAL:
                    if (paned.position < start.height_request) {
                        paned.position = start.height_request;
                    } else if (paned.position > paned.get_height () - end.height_request) {
                        paned.position = paned.get_height () - end.height_request;
                    }
                    break;
            }
        });
    }

    public T autowire<T> () {
        var container = Window.temp;
        return (T)container.find_type (typeof (T));
    }

    public Adw.MessageDialog create_dialog (string heading, string body) {
        var window = Application.app.active_window;
        var dialog = new Adw.MessageDialog (window, heading, body);

        dialog.close_response = "okay";
        dialog.add_response ("okay", "OK");

        return dialog;
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

            //  Thread.usleep ((ulong)1e6);
            this.task ();
        }
    }
}