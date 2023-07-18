namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure.ui")]
    public class TableStructure : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;

        private Table table;
        private ObservableArrayList<Table.Row> data_model;
        private Gtk.SingleSelection selection_model;

        public TableStructure () {
            Object ();
        }

        construct {

            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            signals.table_selected_changed.connect ((schema, tbname) => {
                debug ("%s, %s", schema, tbname);

                query_service.db_table_info.begin (schema, tbname, (obj, res) => {
                    this.table = query_service.db_table_info.end (res);

                    data_model.clear ();
                    foreach (var row in table) {
                        data_model.add (row);
                    }
                });
            });

            var titles = new string[] {
                "Column Name",
                "Type",
                "Length",
                "Nullable",
                "Default Value"
            };

            data_model = new ObservableArrayList<Table.Row> ();

            foreach (var title in titles) {
                var factory = new Gtk.SignalListItemFactory ();

                factory.setup.connect ((_fact, _item) => {
                    var label = new Gtk.Label (null);
                    _item.child = label;
                });

                factory.bind.connect ((_fact, _item) => {
                    var row = _item.item as Table.Row;
                    var label = _item.child as Gtk.Label;
                    label.label = row.get_field (title) ?? "UNKNOWN";
                });

                Gtk.ColumnViewColumn column = new Gtk.ColumnViewColumn (title, factory);
                column.set_expand (true);
                columns.append_column (column);
            }

            selection_model = new Gtk.SingleSelection (data_model);
            columns.set_model (selection_model);
        }

        [GtkChild]
        private unowned Gtk.ColumnView columns;
        [GtkChild]
        private unowned Gtk.ColumnView indexes;
        [GtkChild]
        private unowned Gtk.ColumnView foreign_key;
    }

    public class TableFactory : Object {
        public Gtk.SignalListItemFactory data { get; private set; }


        public TableFactory () {
            Object ();
        }

        construct {
            data = new Gtk.SignalListItemFactory ();
            data.setup.connect (list_item_setup);
            data.bind.connect (list_item_bind);
        }

        public void list_item_setup (Gtk.SignalListItemFactory fact, Gtk.ListItem item) {
            var switch_ = new Gtk.Switch ();
            item.set_child (switch_);

            debug ("setup");
        }

        public void list_item_bind (Gtk.SignalListItemFactory fact, Gtk.ListItem item) {
            var row = item.item as Table.Row;
            // var label = item.child as Gtk.Label;
            // label.set_label ("Ahihi");

            // debug ("bind: %s", label.label);
        }
    }
}