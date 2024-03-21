namespace Psequel {
[GtkTemplate(ui = "/me/ppvan/psequel/gtk/table-data-view.ui")]
public class TableDataView : Gtk.Box {
    public TableDataViewModel tabledata_viewmodel { get; set; }

    public TableDataView() {
        Object();
    }

    construct {
        tabledata_viewmodel = autowire <TableDataViewModel> ();
    }

    [GtkCallback]
    private void reload_data(Gtk.Button btn) {
        btn.sensitive = false;
        tabledata_viewmodel.reload_data.begin((obj, res) => {
                var window      = get_parrent_window(this);
                Adw.Toast toast = new Adw.Toast("Data Reloaded") {
                    timeout = 1,
                };
                window.add_toast(toast);
                btn.sensitive = true;
            });
    }

    [GtkCallback]
    private async void next_page() {
        yield tabledata_viewmodel.next_page();
    }

    [GtkCallback]
    private async void pre_page() {
        yield tabledata_viewmodel.pre_page();
    }
}
}
