namespace Psequel {
[GtkTemplate(ui = "/me/ppvan/psequel/gtk/edit-row.ui")]
public class EditRowDialog : Adw.Dialog {

    private TableDataViewModel tabledata_viewmodel;
    private Relation.Row current_row;

    public EditRowDialog(Relation.Row current_row) {
        Object();
        this.current_row = current_row;
    }
    
    construct {
        this.tabledata_viewmodel = autowire<TableDataViewModel> ();
    }


    public new void present (Gtk.Widget? parent) {
        var table = this.tabledata_viewmodel.selected_table;
        var current_relation = this.tabledata_viewmodel.current_relation;

        int index = 0;
        foreach (var col in table.columns) {
            var label = new Gtk.Label (col.name);
            label.halign = Gtk.Align.START;
            grid.attach (label, 0, index, 1, 1);

            var entry = new Gtk.Entry ();
            var default_value = (current_row.get_by_header (col.name)) ?? "";
            entry.text = default_value;
            grid.attach (entry, 1, index, 3, 1);

            index++;
        }

        base.present (parent);
    }


    [GtkChild]
    private unowned Gtk.Grid grid;
}
}
