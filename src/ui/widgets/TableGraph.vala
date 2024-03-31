using Rsvg;

namespace Psequel {
[GtkTemplate(ui = "/me/ppvan/psequel/gtk/table-graph.ui")]
public class TableGraph : Gtk.Box {
    private uint8[] buff;

    private TableStructureViewModel viewmodel;


    public TableGraph() {
        Object();
    }

    construct {
        this.viewmodel = autowire <TableStructureViewModel>();

        this.viewmodel.notify["selected-table"].connect(() => {
            debug ("Test: %s", this.viewmodel.selected_table.name);
                var table = this.viewmodel.selected_table;
                this.render_graph.begin(table);
            });
    }

    public async void render_graph(Table table) {
        var     fks          = this.viewmodel.foreign_keys;
        uint8[] buff         = generate_graph(table, fks.to_list());
        var     svgPaintable = new SvgPaintable(buff);

        pic.set_paintable(svgPaintable);
        debug ("Test svgPaintable: %d %d %d", fks.size, this.viewmodel.columns.size, this.viewmodel.indexes.size);
    }

    public uint8[] generate_graph(Table table, List <ForeignKey> fks) {
        var gvc = new Gvc.Context();
        var g   = new Gvc.Graph("g", Gvc.Agdirected, 0);
        g.safe_set("rankdir", "LR", "");
        g.safe_set("fontname", "Roboto", "");
        g.safe_set("bgcolor", "transparent", "");

        foreach (var item in fks)
        {
            if (item.table != table.name && item.fk_table != table.name)
            {
                continue;
            }

            var begin = g.create_node(item.table);
            var end   = g.create_node(item.fk_table);

            var begin_label = generate_table_details(g, item.table);
            var end_label   = generate_table_details(g, item.fk_table);

            begin.safe_set("fontname", "Roboto", "");
            begin.safe_set("shape", "plaintext", "");
            begin.safe_set("label", begin_label, "");
            begin.safe_set("fontcolor", "#D1CDC7", "");
            begin.safe_set("color", "#858786", "");


            end.safe_set("fontname", "Roboto", "");
            end.safe_set("shape", "plaintext", "");
            end.safe_set("label", end_label, "");
            end.safe_set("fontcolor", "#D1CDC7", "");
            end.safe_set("color", "#858786", "");
            var edge = g.create_edge(begin, end);
            edge.safe_set("color", "#858786", "");
            edge.safe_set("tailport", item.fk_columns_v2[0], "");
            edge.safe_set("headport", item.columns_v2[0], "");
        }
        gvc.layout(g, "dot");
        gvc.render_data(g, "svg", out this.buff);
        gvc.free_layout(g);

        return(this.buff);
    }

    private Gvc.HtmlString generate_table_details(Gvc.Graph g, string table) {
        var stringBuilder = new StringBuilder("""<table border="0" cellborder="1" cellspacing="0">""");
        stringBuilder.append(@"<tr><td bgcolor=\"#858786\" colspan=\"2\"><b><font color=\"#272727\">$(table)</font></b></td></tr>");
        string[] current_pks = new string[0];
        string[] current_fks = new string[0];

        foreach (var pk in this.viewmodel.primary_keys)
        {
            if (pk.table == table)
            {
                current_pks = pk.columns;
                break;
            }
        }

        foreach (var fk in this.viewmodel.foreign_keys)
        {
            if (fk.table == table)
            {
                current_fks = fk.columns_v2;
                break;
            }
        }

        debug (table);

        for (int i = 0; i < current_pks.length; i++) {
            debug("PK: %s", current_pks[i]);
        }

        for (int i = 0; i < current_fks.length; i++) {
            debug("FK: %s", current_fks[i]);
        }

        foreach (var col in this.viewmodel.columns)
        {
            if (col.table != table)
            {
                continue;
            }

            if (col.name in current_fks)
            {
                stringBuilder.append_printf("""<tr><td align="left">%s</td><td align="right" port="%s">%s</td></tr>""", col.name, col.name, col.column_type);
            }
            else if (col.name in current_pks)
            {
                stringBuilder.append_printf("""<tr><td align="left" port="%s">%s</td><td align="right">%s</td></tr>""", col.name, col.name, col.column_type);
            }
            else
            {
                stringBuilder.append_printf("""<tr><td align="left">%s</td><td align="right" port="%s">%s</td></tr>""", col.name, col.name, col.column_type);
            }
        }

        stringBuilder.append("</table>");
        var markup = stringBuilder.free_and_steal();
        return(Gvc.HtmlString.make_html(g, markup));
    }

    [GtkChild]
    private unowned Gtk.Picture pic;
}
}
