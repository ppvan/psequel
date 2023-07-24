

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-cols.ui")]
    public class TableColInfo : Adw.Bin {

        private Gtk.SelectionModel selection_model;

        private Gtk.StringFilter filter;

        private ObservableArrayList<Column> _model;
        public ObservableArrayList<Column> model {
            get {
                return _model;
            }
            set {
                _model = value;
                bind_model (_model);
            }
        }

        private string _selected_table;
        public string table {
            get {
                return _selected_table;
            }
            set {
                _selected_table = value;
                filter.search = value;
            }
        }



        public TableColInfo () {
            Object ();
        }

        private void bind_model (ListModel model) {
            var filter_model = new Gtk.FilterListModel (model, filter);
            selection_model = new Gtk.NoSelection (filter_model);
            view.set_model (selection_model);
        }

        construct {
            setup_name_col ();
            setup_datatype_col ();
            setup_nullable_col ();
            setup_default_col ();

            var expression = new Gtk.PropertyExpression (typeof (Column), null, "table");
            this.filter = new Gtk.StringFilter (expression);
            this.filter.match_mode = Gtk.StringFilterMatchMode.EXACT;
            this.filter.search = " "; // trick to filter all if no table selected.
        }


        private void setup_name_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as Column;
                var label = listitem.child as Gtk.Label;
                label.label = item.name;
            });
            var col = new Gtk.ColumnViewColumn ("Column Name", factory);
            col.fixed_width = 250;
            view.append_column (col);
        }

        private void setup_datatype_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;

                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as Column;
                var label = listitem.child as Gtk.Label;
                label.label = item.column_type;
            });
            var col = new Gtk.ColumnViewColumn ("Data Type", factory);
            col.fixed_width = 300;
            view.append_column (col);
        }

        private void setup_nullable_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as Column;
                var label = listitem.child as Gtk.Label;
                label.label = item.nullable ? "YES" : "NO";
            });
            var col = new Gtk.ColumnViewColumn ("Nullable", factory);
            col.fixed_width = 70;

            view.append_column (col);
        }

        private void setup_default_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.END;
                label.margin_end = 4;
                label.margin_start = 4;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as Column;
                var label = listitem.child as Gtk.Label;
                label.label = item.default_val;
            });
            var col = new Gtk.ColumnViewColumn ("Default Value", factory);
            col.set_expand (true);
            view.append_column (col);
        }


        [GtkChild]
        private unowned Gtk.ColumnView view;
    }
}