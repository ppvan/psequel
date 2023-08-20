

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-fk.ui")]
    public class TableFKInfo : Adw.Bin {

        public ObservableList<ForeignKey> fks { get; set; }


        public TableFKInfo () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_name_col ();
            setup_table_columns_col ();
            setup_fk_tbname_col ();
            setup_fk_table_columns_col ();
            setup_on_update_col ();
            setup_fk_on_delete_col ();
        }


        private void setup_name_col () {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
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
            factory.setup.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
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
            factory.setup.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
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
            factory.setup.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.START;
                listitem.child = label;
            });
            factory.bind.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
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
            factory.setup.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.CENTER;
                listitem.child = label;
            });
            factory.bind.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
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
            factory.setup.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
                var label = new Gtk.Label (null);
                label.halign = Gtk.Align.CENTER;
                listitem.child = label;
            });
            factory.bind.connect ((obj) => {
                var listitem = obj as Gtk.ListItem;
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