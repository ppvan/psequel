using Gtk;

namespace Psequel {
[GtkTemplate(ui = "/me/ppvan/psequel/gtk/table-row.ui")]
class TableRow : Gtk.Box {
    public string content { get; set; default = ""; }
    public string icon_name { get; set; default = ""; }

    private TableDataViewModel tabledata_viewmodel { get; set; }


    const ActionEntry[] ACTION_ENTRIES = {
        { "copy",    on_row_copy    },
        { "refresh", on_row_refresh },
    };

    public TableRow() {
        Object();
    }

    construct {
        var action_group = new SimpleActionGroup();
        action_group.add_action_entries(ACTION_ENTRIES, this);
        this.insert_action_group("sidebar", action_group);
        tabledata_viewmodel = autowire <TableDataViewModel> ();
    }


    [GtkCallback]
    public void on_right_clicked() {
        popover.popup();
    }

    // [GtkAction]
    private void on_row_copy() {
        clipboard_push(this.content);

        var       window = get_parrent_window(this);
        Adw.Toast toast  = new Adw.Toast("Table name copied") {
            timeout = 1,
        };
        window.add_toast(toast);
    }

    private void on_row_refresh() {
        //  General idea: Loop throught the single selection model
        //  Assume the content of the label item is the same as the model-item.name
        //  and the list view is a single selection.

        var                 listview_type = GLib.Type.from_name("GtkListView");
        Gtk.ListView        view          = this.get_ancestor(listview_type) as Gtk.ListView;
        Gtk.SingleSelection model         = view.model as Gtk.SingleSelection;

        uint n = model.get_n_items();

        for (uint i = 0; i < n; i++)
        {
            Object obj = model.model.get_item(i);
            Value  v   = {};
            obj.get_property("name", ref v);
            string key = v.get_string();

            if (key == this.content)
            {
                model.select_item(i, true);
                view.activate(i);

                var       window = get_parrent_window(this);
                Adw.Toast toast  = new Adw.Toast(@"\"$content\" Refreshed") {
                    timeout = 1,
                };
                window.add_toast(toast);

                break;
            }
        }



        //  view.activate();
    }

    private void clipboard_push(string text) {
        var primary   = Gdk.Display.get_default();
        var clipboard = primary.get_clipboard();

        clipboard.set_text(text);
    }

    [GtkChild]
    private unowned Gtk.Popover popover;
}
}
