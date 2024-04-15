using Gtk;
using Gdk;
namespace Psequel {
public interface Shape : Object {
    public abstract void draw(Cairo.Context cr);
}

public sealed class TextBox : Object, Shape {
    public static int DEFAULT_PAD = 8;

    private string text;
    private Gdk.Rectangle boundary;

    public enum Align
    {
        CENTER,
        LEFT,
        RIGHT
    }

    public Pango.FontDescription custom_font { get; set; default = Pango.FontDescription.from_string("Roboto 16"); }
    public Gdk.RGBA color { get; set; default = { 0, 0, 0, 1 }; }
    public Gdk.RGBA bg_color { get; set; default = { 0, 0, 0, 0.0f }; }
    public Align text_align { get; set; default = Align.CENTER; }
    public bool show_box { get; set; default = true; }

    public TextBox(string text, Gdk.Rectangle rect) {
        base();
        this.text     = text;
        this.boundary = rect;
    }

    public void draw(Cairo.Context cr) {
        cr.move_to(boundary.x, boundary.y);

        if ((show_box))
        {
            cr.save();
            cr.set_source_rgba(bg_color.red, bg_color.green, bg_color.blue, bg_color.alpha);
            cr.rectangle(boundary.x, boundary.y, boundary.width, boundary.height);
            cr.fill();

            cr.restore();
            cr.set_source_rgba(color.red, color.green, color.blue, color.alpha);
            cr.rectangle(boundary.x, boundary.y, boundary.width, boundary.height);
            cr.stroke();
        }

        int text_w = 0, text_h = 0;

        var layout = Pango.cairo_create_layout(cr);
        layout.set_font_description(custom_font);
        layout.set_text(text, -1);
        layout.get_pixel_size(out text_w, out text_h);
        layout.set_width((boundary.width - 2 * TextBox.DEFAULT_PAD) * Pango.SCALE);
        layout.set_height((boundary.height - 2 * TextBox.DEFAULT_PAD) * Pango.SCALE);
        layout.set_ellipsize(Pango.EllipsizeMode.MIDDLE);
        layout.set_alignment(Pango.Alignment.CENTER);

        cr.move_to(boundary.x + TextBox.DEFAULT_PAD, boundary.y + (boundary.height - text_h) / 2);
        switch (text_align)
        {
        case Align.CENTER:
            layout.set_alignment(Pango.Alignment.CENTER);
            break;

        case Align.LEFT:
            layout.set_alignment(Pango.Alignment.LEFT);
            break;

        case Align.RIGHT:
            layout.set_alignment(Pango.Alignment.RIGHT);
            break;

        default:
            assert_not_reached();
        }

        cr.set_source_rgba(color.red, color.green, color.blue, color.alpha);
        Pango.cairo_show_layout(cr, layout);
        cr.stroke();
    }
}

public sealed class TableBox : Object, Shape {
    private Table table;


    public Gdk.Rectangle boundary { get; set; default = { 0, 0, 100, 100 }; }
    public Gdk.RGBA color { get; set; default = { 1, 1, 1, 1 }; }


    //  Computed from ui-state

    private bool isHover = false;


    public TableBox(Table table) {
        this.table = table;
    }

    public void update(UIContext ctx) {
        this.isHover = this.boundary.contains_point((int)ctx.mouse_x, (int)ctx.mouse_y);
    }

    public void draw(Cairo.Context cr) {
        cr.move_to(boundary.x, boundary.y);

        if (isHover)
        {
            cr.set_source_rgba(1, 0, 0, color.alpha);
        }
        else
        {
            cr.set_source_rgba(color.red, color.green, color.blue, color.alpha);
        }

        cr.rectangle(boundary.x, boundary.y, boundary.width, boundary.height);
        cr.stroke();

        int row_height = boundary.height / (1 + table.columns.length);
        var header     = new TextBox(table.name, { boundary.x, boundary.y, boundary.width, row_height });
        header.custom_font.set_weight(Pango.Weight.BOLD);
        header.bg_color = { 64 / 255f, 64 / 255f, 64 / 255f, 1 };
        header.color    = this.color;
        header.draw(cr);


        int index = 1;
        foreach (var column in table.columns)
        {
            var col_name = new TextBox(column.name, { boundary.x, boundary.y + index * row_height, boundary.width / 2, row_height });
            col_name.color      = this.color;
            col_name.text_align = TextBox.Align.LEFT;

            var col_type = new TextBox(column.column_type, { boundary.x + boundary.width / 2, boundary.y + index * row_height, boundary.width / 2, row_height });
            col_type.color      = this.color;
            col_type.text_align = TextBox.Align.RIGHT;

            col_name.draw(cr);
            col_type.draw(cr);
            index++;
        }
    }
}


public sealed class CairoIcon : Object, Shape {
    private string filepath;

    public CairoIcon(string iconname) {
        //  uint8[] file_content;

        var filename = "resource:///me/ppvan/psequel/icons/scalable/actions/%s.svg".printf(iconname);
        var file     = File.new_for_uri(filename);
        //  file.load_contents(null, out file_content, null);

        this.filepath = file.get_path();

        //  debug(filepath);
        //  debug ((string)file_content);
    }

    public void draw(Cairo.Context cr) {
        //  Cairo.SvgSurface surface = new Cairo.SvgSurface(this.filepath, 48, 48);
        //  cr.set_source_surface(surface, 0, 0);
    }
}
}
