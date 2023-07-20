using Gee;
namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-data.ui")]
    public class TableData : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;

        private ObservableArrayList<Relation.Row> model;

        private ArrayList<Gtk.ColumnViewColumn> backup;

        public TableData () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            model = new ObservableArrayList<Relation.Row> ();
            backup = new ArrayList<Gtk.ColumnViewColumn> ();

            signals.table_selected_changed.connect ((schema, tbname) => {
                load_data.begin (schema, tbname);
            });

            int created = 0;
            int binded = 0;

            for (int i = 0; i < 20; i++) {
                var factory = new Gtk.SignalListItemFactory ();
                factory.set_data<int> ("index", i);

                factory.setup.connect ((_fact, _item) => {
                    var label = new Gtk.Label (null);
                    label.halign = Gtk.Align.START;
                    label.margin_start = 8;
                    _item.child = label;
                    created++;

                    debug ("Create %d", created);
                });

                factory.bind.connect ((_fact, _item) => {
                    var row = _item.item as Relation.Row;
                    var label = _item.child as Gtk.Label;
                    int index = _fact.get_data<int> ("index");
                    label.label = row[index];
                    binded++;

                    debug ("Bind %d", binded);
                });

                factory.unbind.connect ((_fact, _item) => {
                    binded--;
                });


                factory.teardown.connect ((_fact, _item) => {
                    created--;
                });

                Gtk.ColumnViewColumn column = new Gtk.ColumnViewColumn ("", factory);
                column.set_expand (true);
                data_view.append_column (column);

                var selection_model = new Gtk.SingleSelection (model);
                data_view.set_model (selection_model);
            }
        }


        public void table_double_clicked () {
            debug ("Activated");
        }

        public async void load_data (string schema, string table_name) {
            Relation relation = yield query_service.select (schema, table_name, 1000);

            debug (relation.to_string ());

            model.clear ();
            foreach (var item in relation) {
                model.add (item);
            }
        }

        [GtkChild]
        private unowned Gtk.ColumnView data_view;

    }
}