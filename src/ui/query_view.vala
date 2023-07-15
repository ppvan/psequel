

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {

        private unowned QueryService query_service;


        private ObservableArrayList<Table.Row> table_names;

        public QueryView () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            table_names = new ObservableArrayList<Table.Row> ();

            table_list.bind_model (table_names, table_row_factory);
        }

        [GtkCallback]
        private void on_reload_clicked () {
            reload_tables.begin ();
        }

        private async void reload_tables () throws PsequelError {

            var cur_schema = (string) schema.selected_item;

            var relations = yield query_service.db_tablenames (cur_schema);

            table_names.clear ();
            foreach (var item in relations) {
                debug (item.to_string ());
                table_names.add (item);
            }
        }

        /** Create row widget from data
         */
        private Gtk.ListBoxRow table_row_factory (Object obj) {
            var row_data = obj as Table.Row;

            var row = new Gtk.ListBoxRow ();

            row.child = new Gtk.Label (row_data[0]);

            return row;
        }

        [GtkChild]
        private unowned Gtk.Button reload;

        [GtkChild]
        private unowned Gtk.ListBox table_list;

        [GtkChild]
        private unowned Gtk.DropDown schema;
    }
}