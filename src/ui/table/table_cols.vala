

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-cols.ui")]
    public class TableColInfo : Adw.Bin {

        public ObservableList<Column> columns;

        public TableColInfo () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_name_col ();
            setup_datatype_col ();
            setup_nullable_col ();
            setup_default_col ();
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