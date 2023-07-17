namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure.ui")]
    public class TableStructure : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;

        public TableStructure () {
            Object ();
        }

        construct {

            query_service = ResourceManager.instance ().query_service;
            signals = ResourceManager.instance ().signals;

            signals.database_connected.connect (() => {
                query_service.db_table_info.begin ("public", "city", (object, res) => {
                    Table table = query_service.db_table_info.end (res);

                    debug (table.to_string ());
                    foreach (var item in table) {
                        debug (item.to_string ());
                    }
                });
            });

        }

        [GtkChild]
        private Gtk.ColumnView columns;
        [GtkChild]
        private Gtk.ColumnView indexes;
        [GtkChild]
        private Gtk.ColumnView foreign_key;
    }
}