namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-results.ui")]
    public class QueryResults : Adw.Bin {

        const string MAIN = "main";
        const string LOADING = "loading";

        private ObservableArrayList<Relation.Row> model;

        private Gtk.SortListModel sort_model;
        private Gtk.SelectionModel selection_model;

        public class QueryResults () {
            Object ();
        }

        construct {

            stack.visible_child_name = LOADING;
            spinner.spinning = false;
            model = new ObservableArrayList<Relation.Row> ();
            // construct columns
            alloc_columns ();
        }

        private async void load_data_to_view (Relation relation) {
            var columns = data_view.columns;
            uint n = columns.get_n_items ();

            Timeout.add_seconds (1, () => {
                load_data_to_view.callback ();
                return false;
            }, Priority.DEFAULT);
            yield;


            debug ("Begin add rows to views");
            for (int i = 0; i < n; i++) {
                var col = columns.get_item (i) as Gtk.ColumnViewColumn;
                if (i >= relation.cols) {
                    col.set_visible (false);
                    continue;
                }
                auto_set_sorter (col, relation.get_column_type (i), i);
                col.set_title (relation.get_header (i));
                col.set_visible (true);
            }

            this.selection_model.unselect_all ();
            model.clear ();

            model.batch_add (relation.iterator ());
        }

        public void load_result (Relation relation) {
            stack.visible_child_name = LOADING;
            spinner.spinning = true;

            load_data_to_view.begin (relation, (obj, res) => {
                stack.visible_child_name = MAIN;
                spinner.spinning = false;
            });

            // Show loadding state
            // load data in background
            // show data
        }

        private void alloc_columns () {
            for (int i = 0; i < ResourceManager.MAX_COLUMNS; i++) {
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

                Gtk.ColumnViewColumn column = new Gtk.ColumnViewColumn ("", factory);
                column.set_expand (true);
                // column.fixed_width = 200;
                column.set_visible (false);

                data_view.append_column (column);
            }

            this.sort_model = new Gtk.SortListModel (model, null);
            this.sort_model.incremental = true;

            this.selection_model = new Gtk.SingleSelection (sort_model);

            data_view.set_model (this.selection_model);
        }

        private void auto_set_sorter (Gtk.ColumnViewColumn col, Type type, int col_index) {
            switch (type) {
            case Type.BOOLEAN, Type.INT64, Type.FLOAT, Type.DOUBLE:
                var constexprs = new Gtk.ConstantExpression (Type.INT, col_index);
                var expresion = new Gtk.CClosureExpression (Type.INT64, null, { constexprs }, (Callback) get_col_by_index_int, null, null);

                var sorter = new Gtk.NumericSorter (expresion);

                col.set_sorter (sorter);
                break;

            default:
                var constexprs = new Gtk.ConstantExpression (Type.INT, col_index);
                var expresion = new Gtk.CClosureExpression (Type.STRING, null, { constexprs }, (Callback) get_col_by_index, null, null);

                var sorter = new Gtk.StringSorter (expresion);

                col.set_sorter (sorter);
                break;
            }
        }

        [GtkChild]
        private unowned Gtk.Stack stack;

        [GtkChild]
        private unowned Gtk.ColumnView data_view;

        [GtkChild]
        private unowned Gtk.Spinner spinner;
    }
}