namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure-view.ui")]
    public class TableStructure : Gtk.Box {

        private unowned WindowSignals signals;

        private Schema _cur_schema;

        // Keep ref for the factory to exist.
        //  private Gee.ArrayList<Gtk.SignalListItemFactory> facts;
        //  private Gtk.StringFilter col_filter;
        //  private Gtk.StringFilter idx_filter;
        //  private Gtk.StringFilter fk_filter;

        private Schema cur_schema {
            get {
                return _cur_schema;
            }
            set {
                _cur_schema = value;
                columns.model = _cur_schema.columns;
                indexes.model = _cur_schema.indexes;
                foreign_keys.model = _cur_schema.fks;
            }
        }

        public TableStructure () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_signals ();
        }

        private void setup_signals () {

            // signals can only be connected after the window is ready.
            // because widget access window to get signals.
            ResourceManager.instance ().app_signals.window_ready.connect (() => {
                signals = get_parrent_window (this).signals;

                signals.schema_changed.connect ((schema) => {
                    debug ("%s", schema.name);
                    cur_schema = schema;
    
                    columns.table = " ";
                    indexes.table = " ";
                    foreign_keys.table = " ";
                });
    
                signals.table_selected_changed.connect ((tbname) => {
                    debug ("Handle table_selected_changed: %s", tbname);
                    columns.table = tbname;
                    indexes.table = tbname;
                    foreign_keys.table = tbname;
                });
            });

        }


        [GtkChild]
        private unowned TableColInfo columns;
        [GtkChild]
        private unowned TableIndexInfo indexes;
        [GtkChild]
        private unowned TableFKInfo foreign_keys;
    }

}