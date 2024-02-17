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


    public Adw.MessageDialog create_dialog (string heading, string body) {
        var app = autowire<Application> ();
        var window = app.active_window;
        var dialog = new Adw.MessageDialog (window, heading, body);

        dialog.close_response = "okay";
        dialog.add_response ("okay", "OK");

        return dialog;
    }
}