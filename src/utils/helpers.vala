namespace Psequel {
public Window get_parrent_window(Gtk.Widget widget) {
    var window = widget.get_root();

    if (window is Psequel.Window)
    {
        return((Window)window);
    }
    else
    {
        warning("Widget %s root is not a window", widget.name);
        assert_not_reached();
    }
}

/** Why it has to be like this? you ask. Because i don't find a way to limit paned postion that never hide it's child */
public void setup_paned(Gtk.Paned paned) {
    paned.notify["position"].connect(() => {
            var start = paned.start_child;
            var end   = paned.end_child;

            switch (paned.orientation)
            {
                case Gtk.Orientation.HORIZONTAL:
                    if (paned.position < start.width_request)
                    {
                        paned.position = start.width_request;
                    }
                    else if (paned.position > paned.get_width() - end.width_request)
                    {
                        paned.position = paned.get_width() - end.width_request;
                    }
                    break;

                case Gtk.Orientation.VERTICAL:
                    if (paned.position < start.height_request)
                    {
                        paned.position = start.height_request;
                    }
                    else if (paned.position > paned.get_height() - end.height_request)
                    {
                        paned.position = paned.get_height() - end.height_request;
                    }
                    break;
            }
        });
}

public Adw.MessageDialog create_dialog(string heading, string body) {
    var app    = autowire <Application> ();
    var window = app.active_window;
    var dialog = new Adw.MessageDialog(window, heading, body);

    debug(body);

    dialog.close_response = "okay";
    dialog.add_response("okay", "OK");

    return(dialog);
}

public class MonospaceFilter : Gtk.Filter {
    public override bool match(GLib.Object ?item) {
        if (item is Pango.FontFace)
        {
            var fontface = item as Pango.FontFace;
            return(fontface.get_family().is_monospace());
        }
        else if (item is Pango.FontFamily)
        {
            var family = item as Pango.FontFamily;
            return(family.is_monospace());
        }
        else
        {
            debug("Check the FontDialog docs: https://docs.gtk.org/gtk4/method.FontDialog.set_filter.html");
            assert_not_reached();
        }
    }
}


public class SvgPaintable : Gdk.Paintable, Object {
    public uint8[] data { get; set; }
    public Rsvg.Handle handle { get; private set; }

    public SvgPaintable(uint8[] data) {
        this.data = data;
        this.handle = new Rsvg.Handle.from_data(this.data);
    }


    public void snapshot(Gdk.Snapshot snapshot, double width, double height) {
        var           gtkSnapshot = snapshot as Gtk.Snapshot;
        Graphene.Rect rect        = Graphene.Rect() {
        };
        rect = rect.init(0, 0, (float)width, (float)height);

        var svgRect = Rsvg.Rectangle() {
            x      = 0,
            y      = 0,
            width  = width,
            height = height
        };


        var cr = gtkSnapshot.append_cairo(rect);

        try {
            this.handle.render_document(cr, svgRect);
        } catch (GLib.Error err) {
            debug(err.message);
        }
    }

    public int get_intrinsic_width() {
        double width;
        handle.get_intrinsic_size_in_pixels(out width, null);

        return((int)Math.ceil(width));
    }

    public int get_intrinsic_height() {
        double height;
        handle.get_intrinsic_size_in_pixels(null, out height);

        return((int)Math.ceil(height));
    }
}
}
