namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-results.ui")]
    public class QueryResults : Adw.Bin {

        const string EMPTY = "empty";
        const string MAIN = "data";
        const string LOADING = "loading";
        const string ERROR = "error";

        public string wellcome_message { get; set; }

        private Relation _current_relation;
        public Relation current_relation {
            get {
                return _current_relation;
            }
            set {
                if (value == null) {
                    return;
                }
                _current_relation = value;
                on_current_relation_change ();
            }
        }
        public bool is_loading { get; set; }

        private string _err_msg = "";
        public string err_msg {
            get {
                return _err_msg;
            }
            set {
                if (value == null) {
                    return;
                }
                _err_msg = value;
                on_err_message_change ();
            }
        }

        private ObservableList<Relation.Row> rows;
        private Gtk.SortListModel sort_model;
        private Gtk.SelectionModel selection_model;

        public class QueryResults () {
            Object ();
        }

        construct {
            stack.visible_child_name = EMPTY;
            rows = new ObservableList<Relation.Row> ();
            alloc_columns ();
        }

        private void on_current_relation_change () {
            debug ("%d ", current_relation.rows);
            stack.visible_child_name = LOADING;
            load_data_to_view.begin (current_relation, (obj, res) => {
                stack.visible_child_name = MAIN;
            });
        }

        private void on_err_message_change () {
            stack.visible_child_name = ERROR;
        }

        private async void load_data_to_view (Relation relation) {
            // if (relation == null) {
            // return;
            // }

            var columns = data_view.columns;
            uint n = columns.get_n_items ();
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
            this.sort_model.sorter = data_view.get_sorter ();
            rows.clear ();

            foreach (var row in relation) {
                rows.append (row);
            }
        }

        private void alloc_columns () {
            for (int i = 0; i < Application.MAX_COLUMNS; i++) {
                var factory = new Gtk.SignalListItemFactory ();
                factory.set_data<int> ("index", i);

                factory.setup.connect ((_fact, obj) => {

                    var _item = (Gtk.ListItem) obj;
                    var label = new Gtk.Label (null);
                    label.halign = Gtk.Align.START;
                    label.margin_start = 8;
                    _item.child = label;
                });

                factory.bind.connect ((_fact, obj) => {
                    var _item = (Gtk.ListItem) obj;
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

            this.sort_model = new Gtk.SortListModel (rows, null);
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

        // [GtkChild]
        // private unowned Gtk.Spinner spinner;

        // [GtkChild]
        // private unowned Gtk.Label status_label;
    }

    /*
     */
    public string get_col_by_index (Relation.Row row, int index) {
        return row[index];
    }

    public int64 get_col_by_index_int (Relation.Row row, int index) {
        return int64.parse (row[index], 10);
    }
}