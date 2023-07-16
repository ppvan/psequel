

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {

        private unowned QueryService query_service;
        private unowned AppSignals signals;


        private ObservableArrayList<Table.Row> table_names;

        public QueryView () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;
            table_names = new ObservableArrayList<Table.Row> ();

            table_list.bind_model (table_names, table_row_factory);

            signals.table_list_changed.connect (() => {
                debug ("Handle table_list_changed.");
                reload_tables.begin ();
            });
        }

        [GtkCallback]
        private void on_reload_clicked () {

            debug ("Emit table_list_changed");
            signals.table_list_changed ();
        }

        [GtkCallback]
        private void on_logout_clicked () {

            debug ("clicked");
            var window = (Window) ResourceManager.instance ().app.get_active_window ();
            window.navigate_to ("connection-view");
        }

        private async void reload_tables () throws PsequelError {

            var cur_schema = (string) schema.selected_item;

            var relations = yield query_service.db_tablenames (cur_schema);

            table_names.clear ();
            foreach (var item in relations) {
                table_names.add (item);
            }
        }

        /** Create row widget from data
         */
        private Gtk.ListBoxRow table_row_factory (Object obj) {
            var row_data = obj as Table.Row;

            var row = new Gtk.ListBoxRow ();

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
            var icon = new Gtk.Image ();
            icon.icon_name = "table-symbolic";
            var label = new Gtk.Label (row_data[0]);

            box.append (icon);
            box.append (label);

            row.child = box;

            return row;
        }

        [GtkChild]
        private unowned Gtk.ListBox table_list;

        [GtkChild]
        private unowned Gtk.Button logout;

        [GtkChild]
        private unowned Gtk.DropDown schema;
    }
}