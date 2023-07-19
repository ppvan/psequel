namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure.ui")]
    public class TableStructure : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;

        //  private Table table;
        private ObservableArrayList<Relation.Row> columns_model;
        private ObservableArrayList<Relation.Row> index_model;
        private ObservableArrayList<Relation.Row> fk_model;
        // private Gtk.SingleSelection selection_model;

        public TableStructure () {
            Object ();
        }

        construct {

            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            columns_model = new ObservableArrayList<Relation.Row> ();
            index_model = new ObservableArrayList<Relation.Row> ();
            fk_model = new ObservableArrayList<Relation.Row> ();


            signals.table_selected_changed.connect ((schema, tbname) => {
                debug ("%s, %s", schema, tbname);
                reload_table_columns.begin (schema, tbname);
                reload_table_indexes.begin (schema, tbname);
                reload_table_fk.begin (schema, tbname);
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
                "Unique",
                "Type",
                "Columns",
            };

            var fk_titles = new string[] {
                "Key Name",
                "Columns",
                "Foreign Table",
                "Foreign Columns",
                "On Update",
                "On Delete",
            };

            set_up_view (columns_title, columns_model, columns);
            set_up_view (index_titles, index_model, indexes);
            set_up_view (fk_titles, fk_model, foreign_key);
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
                    var row = _item.item as Relation.Row;
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
                
                if (relation.cols != columns.columns.get_n_items ()) {
                    debug ("Programming Error: Query result cols != view columns");
                    assert_not_reached ();
                }

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

                if (relation.cols != indexes.columns.get_n_items ()) {
                    debug ("Programming Error: Query result cols != view columns");
                    assert_not_reached ();
                }

                index_model.clear ();
                foreach (var row in relation) {
                    index_model.add (row);
                }

            } catch (PsequelError err) {
                debug (err.message);
            //  ResourceManager.instance ().app
            }
        }

        private async void reload_table_fk (string schema, string tbname) {
            try {
                var relation = yield query_service.db_table_fk (schema, tbname);

                if (relation.cols != foreign_key.columns.get_n_items ()) {
                    debug ("Programming Error: Query result cols != view columns");
                    assert_not_reached ();
                }

                fk_model.clear ();
                foreach (var row in relation) {
                    fk_model.add (row);
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