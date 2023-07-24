using Gee;
namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-data-view.ui")]
    public class TableData : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;

        private ObservableArrayList<Relation.Row> model;

        private ArrayList<Gtk.ColumnViewColumn> backup;

        private Gtk.SortListModel sort_model;


        public int query_limit { get; set; }

        public string schema {get; private set; default = "public";}
        public string tbname {get; private set;}
        public int current_page { get; private set; default = 0; }

        public TableData () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            var setting = ResourceManager.instance ().settings;
            setting.bind ("query-limit", this, "query-limit", SettingsBindFlags.DEFAULT);

            this.bind_property ("current_page", status_label, "label", BindingFlags.SYNC_CREATE, (bindding, from, ref to) => {
                int curr_page = from.get_int ();
                to.set_string (@"Rows $(curr_page * query_limit + 1) - $(query_limit * (curr_page + 1))");

                return true;
            });

            this.bind_property ("current_page", left_page, "sensitive", BindingFlags.SYNC_CREATE, (bindding, from, ref to) => {
                int curr_page = from.get_int ();
                to.set_boolean (curr_page > 0);

                return true;
            });

            model = new ObservableArrayList<Relation.Row> ();
            backup = new ArrayList<Gtk.ColumnViewColumn> ();

            signals.table_activated.connect_after ((schema, tbname) => {
                this.schema = schema;
                this.tbname = tbname;
                this.filter_entry.set_text ("");
                load_data.begin (schema, tbname);
            });

            signals.view_activated.connect_after ((schema, vname) => {
                this.schema = schema;
                this.tbname = tbname;
                this.filter_entry.set_text ("");
                load_data.begin (schema, vname);
            });


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
                column.set_visible (false);

                data_view.append_column (column);

                this.sort_model = new Gtk.SortListModel (model, null);

                // assert_nonnull (model);

                var selection_model = new Gtk.SingleSelection (sort_model);
                data_view.set_model (selection_model);
            }
        }

        [GtkCallback]
        private void filter_query (Gtk.Button btn) {
            var where_clause = filter_entry.get_text ();
            load_data.begin (schema, tbname, current_page, where_clause);
        }

        [GtkCallback]
        private void on_entry_activated (Gtk.Entry entry) {
            filter_btn.clicked ();
        }


        [GtkCallback]
        private void load_next_page (Gtk.Button btn) {
            load_data.begin (schema, tbname, ++current_page);

            
        }

        [GtkCallback]
        private void load_previous_page (Gtk.Button btn) {
            load_data.begin (schema, tbname, --current_page);
        }

        [GtkCallback]
        private void reload_data (Gtk.Button btn) {
            load_data.begin (schema, tbname, current_page);
        }

        public void table_double_clicked () {
            debug ("Activated");
        }

        public async void load_data (string schema, string table_name, int page = 0, string where = "") {

            try {

                Relation relation = yield query_service.select (schema, table_name, page * query_limit, query_limit, where);

                // Show error model.
                debug (relation.to_string ());

                var columns = data_view.columns;
                uint n = data_view.columns.get_n_items ();
                for (uint i = 0; i < n; i++) {
                    var col = columns.get_item (i) as Gtk.ColumnViewColumn;
                    if (i >= relation.cols) {
                        col.set_visible (false);
                        continue;
                    }

                    switch (relation.get_column_type ((int) i)) {
                    case Type.BOOLEAN, Type.INT64, Type.FLOAT, Type.DOUBLE:
                        var constexprs = new Gtk.ConstantExpression (Type.INT, i);
                        var expresion = new Gtk.CClosureExpression (Type.INT64, null, { constexprs }, (Callback) get_col_by_index_int, null, null);

                        var sorter = new Gtk.NumericSorter (expresion);

                        col.set_sorter (sorter);
                        break;

                    default:
                        var constexprs = new Gtk.ConstantExpression (Type.INT, i);
                        var expresion = new Gtk.CClosureExpression (Type.STRING, null, { constexprs }, (Callback) get_col_by_index, null, null);

                        var sorter = new Gtk.StringSorter (expresion);

                        col.set_sorter (sorter);
                        break;
                    }


                    col.set_title (relation.get_header ((int) i));
                    col.set_visible (true);
                }

                this.sort_model.set_sorter (data_view.get_sorter ());

                TimePerf.begin ();
                model.clear ();
                foreach (var item in relation) {
                    model.add (item);
                }

                TimePerf.end ();
            } catch (PsequelError.QUERY_FAIL err) {
                create_dialog ("Query Fail", err.message).present ();
            }
        }

        [GtkChild]
        private unowned Gtk.ColumnView data_view;

        [GtkChild]
        private unowned Gtk.Entry filter_entry;

        [GtkChild]
        private unowned Gtk.Button filter_btn;

        [GtkChild]
        private unowned Gtk.Button left_page;

        [GtkChild]
        private unowned Gtk.Button right_page;

        [GtkChild]
        private unowned Gtk.Label status_label;
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