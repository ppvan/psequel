

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-fk.ui")]
    public class TableFKInfo : Adw.Bin {
        private Gtk.SelectionModel selection_model;

        private Gtk.StringFilter filter;

        private ObservableArrayList<ForeignKey> _model;
        public ObservableArrayList<ForeignKey> model {
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



        public TableFKInfo () {
            Object ();
        }

        private void bind_model (ListModel model) {
            var filter_model = new Gtk.FilterListModel (model, filter);
            filter_model.incremental = true;
            selection_model = new Gtk.NoSelection (filter_model);
            view.set_model (selection_model);
        }

        construct {
            setup_name_col ();
            setup_table_columns_col ();
            setup_fk_tbname_col ();
            setup_fk_table_columns_col ();
            setup_on_update_col ();
            setup_fk_on_delete_col ();


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
                var item = listitem.item as ForeignKey;
                var label = listitem.child as Gtk.Label;
                label.label = item.name;
            });
            var col = new Gtk.ColumnViewColumn ("Foreign Key", factory);
            col.fixed_width = 250;
            view.append_column (col);
        }

        private void setup_table_columns_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as ForeignKey;
                var label = listitem.child as Gtk.Label;
                label.label = item.columns;
            });
            var col = new Gtk.ColumnViewColumn ("Columns", factory);
            col.fixed_width = 250;
            view.append_column (col);
        }

        private void setup_fk_tbname_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as ForeignKey;
                var label = listitem.child as Gtk.Label;
                label.label = item.fk_table;
            });
            var col = new Gtk.ColumnViewColumn ("Foreign Table", factory);
            col.expand = true;
            view.append_column (col);
        }

        private void setup_fk_table_columns_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as ForeignKey;
                var label = listitem.child as Gtk.Label;
                label.label = item.fk_columns;
            });
            var col = new Gtk.ColumnViewColumn ("Reference Columns", factory);
            col.expand = true;
            view.append_column (col);
        }

        private void setup_on_update_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.CENTER;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as ForeignKey;
                var label = listitem.child as Gtk.Label;
                label.label = item.on_update.to_string ();
            });
            var col = new Gtk.ColumnViewColumn ("On Update", factory);
            col.fixed_width = 100;
            view.append_column (col);
        }

        private void setup_fk_on_delete_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((listitem) => {
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.CENTER;
                listitem.child = label;
            });
            factory.bind.connect ((listitem) => {
                var item = listitem.item as ForeignKey;
                var label = listitem.child as Gtk.Label;
                label.label = item.on_delete.to_string ();
            });
            var col = new Gtk.ColumnViewColumn ("On Delete", factory);
            col.fixed_width = 100;
            view.append_column (col);
        }

        [GtkChild]
        private unowned Gtk.ColumnView view;
    }
}