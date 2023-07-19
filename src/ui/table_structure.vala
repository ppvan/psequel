namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure.ui")]
    public class TableStructure : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;

        //  private Table table;
        private ObservableArrayList<Table.Row> columns_model;
        private ObservableArrayList<Table.Row> index_model;
        // private Gtk.SingleSelection selection_model;

        public TableStructure () {
            Object ();
        }

        construct {

            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            columns_model = new ObservableArrayList<Table.Row> ();
            index_model = new ObservableArrayList<Table.Row> ();


            signals.table_selected_changed.connect ((schema, tbname) => {
                debug ("%s, %s", schema, tbname);
                reload_table_columns.begin (schema, tbname);
                reload_table_indexes.begin (schema, tbname);
            });

            var columns_title = new string[] {
                "Column Name",
                "Type",
                "Length",
                "Nullable",
                "Default Value"
            };

            var index_titles = new string[] {
                "Index Name",
                "Index Definition"
            };

            set_up_view (columns_title, columns_model, columns);
            set_up_view (index_titles, index_model, indexes);
        }

        void set_up_view (string[] titles, ListModel model, Gtk.ColumnView view) {
            for (int i = 0; i < titles.length; i++) {
                var factory = new Gtk.SignalListItemFactory ();
                factory.set_data<int> ("index", i);

                factory.setup.connect ((_fact, _item) => {
                    var label = new Gtk.Label (null);
                    label.halign = Gtk.Align.START;
                    label.margin_start = 8;
                    _item.child = label;
                });

                factory.bind.connect ((_fact, _item) => {
                    var row = _item.item as Table.Row;
                    var label = _item.child as Gtk.Label;
                    int index = _fact.get_data<int> ("index");
                    label.label = row[index];
                });

                Gtk.ColumnViewColumn column = new Gtk.ColumnViewColumn (titles[i], factory);
                column.set_expand (true);
                view.append_column (column);
            }

            var selection_model = new Gtk.SingleSelection (model);
            view.set_model (selection_model);
        }

        private async void reload_table_columns (string schema, string tbname) {
            try {
                var relation = yield query_service.db_table_info (schema, tbname);
                columns_model.clear ();
                foreach (var row in relation) {
                    columns_model.add (row);
                }

            } catch (PsequelError err) {
                debug (err.message);
            //  ResourceManager.instance ().app
            }
        }

        private async void reload_table_indexes (string schema, string tbname) {
            try {
                var relation = yield query_service.db_table_indexes (schema, tbname);
                index_model.clear ();
                foreach (var row in relation) {
                    index_model.add (row);
                }

            } catch (PsequelError err) {
                debug (err.message);
            //  ResourceManager.instance ().app
            }
        }

        [GtkChild]
        private unowned Gtk.ColumnView columns;
        [GtkChild]
        private unowned Gtk.ColumnView indexes;
        [GtkChild]
        private unowned Gtk.ColumnView foreign_key;
    }

}