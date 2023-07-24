namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure.ui")]
    public class TableStructure : Gtk.Box {

        private AppSignals signals;
        private QueryService query_service;
        private SchemaService schema_service;

        private Schema _cur_schema;

        // Keep ref for the factory to exist.
        private Gee.ArrayList<Gtk.SignalListItemFactory> facts;
        private Gtk.StringFilter col_filter;
        private Gtk.StringFilter idx_filter;
        private Gtk.StringFilter fk_filter;

        private Schema cur_schema {
            get {
                return _cur_schema;
            }
            set {
                _cur_schema = value;
                Idle.add (() => {
                    bind_model ();
                    return false;
                }, Priority.LOW);
            }
        }
        // private Gtk.SingleSelection selection_model;

        public TableStructure () {
            Object ();
        }

        public void bind_model () {
            bind_columns ();
            bind_indexes ();
            bind_fks ();
        }

        private void bind_columns () {
            var expression = new Gtk.PropertyExpression (typeof (Column), null, "table");
            var filter = new Gtk.StringFilter (expression);
            filter.match_mode = Gtk.StringFilterMatchMode.EXACT;
            this.col_filter = filter;
            var filter_model = new Gtk.FilterListModel (cur_schema.columns, filter);
            var selection = new Gtk.SingleSelection (filter_model);

            columns.set_model (selection);
        }

        private void bind_indexes () {
            var expression = new Gtk.PropertyExpression (typeof (Index), null, "table");
            var filter = new Gtk.StringFilter (expression);
            filter.match_mode = Gtk.StringFilterMatchMode.EXACT;
            this.idx_filter = filter;
            var filter_model = new Gtk.FilterListModel (cur_schema.indexes, filter);
            var selection = new Gtk.SingleSelection (filter_model);

            indexes.set_model (selection);
        }

        private void bind_fks () {
            var expression = new Gtk.PropertyExpression (typeof (ForeignKey), null, "table");
            var filter = new Gtk.StringFilter (expression);
            filter.match_mode = Gtk.StringFilterMatchMode.EXACT;
            this.fk_filter = filter;
            var filter_model = new Gtk.FilterListModel (cur_schema.fks, filter);
            var selection = new Gtk.SingleSelection (filter_model);

            foreign_key.set_model (selection);
        }

        construct {

            //  query_service = ResourceManager.instance ().query_service;
            //  signals = ResourceManager.instance ().signals;
            //  facts = new Gee.ArrayList<Gtk.SignalListItemFactory> ();

            //  schema_service = new SchemaService (query_service);


            //  signals.schema_changed.connect ((schema) => {
            //      debug ("%s", schema.name);
            //      cur_schema = schema;
            //  });

            //  signals.table_selected_changed.connect ((tbname) => {
            //      debug ("Handle table_selected_changed: %s", tbname);
            //      col_filter.search = tbname;
            //      idx_filter.search = tbname;
            //      fk_filter.search = tbname;
            //  });

            //  var cols_info = new ColumnInfo[] {
            //      { "Column Name", "name", Type.STRING },
            //      { "Type", "column_type", Type.STRING },
            //      { "Nullable", "nullable", Type.BOOLEAN },
            //      { "Default Value", "default_val", Type.STRING, true },
            //  };

            //  var idxs_info = new ColumnInfo[] {
            //      { "Index Name", "name", typeof (string) },
            //      { "Type", "index_type", Type.ENUM },
            //      { "Unique", "unique", Type.BOOLEAN },
            //      { "Columns", "columns", Type.STRING, true },
            //      { "Size", "size", Type.STRING },
            //  };

            //  var fk_info = new ColumnInfo[] {
            //      { "ForeignKey Name", "name", Type.STRING },
            //      { "Table", "table", Type.STRING },
            //      { "Columns", "columns", Type.STRING },
            //      { "FK Table", "fk_table", Type.STRING },
            //      { "FK Columns", "fk_columns", Type.STRING },
            //      { "On Update", "on_update", Type.ENUM },
            //      { "On Delete", "on_delete", Type.ENUM },
            //  };

            //  setup_view (columns, cols_info);
            //  setup_view (indexes, idxs_info);
            //  setup_view (foreign_key, fk_info);
        }

        private void setup_view (Gtk.ColumnView view, ColumnInfo[] cols_info) {
            //  for (int i = 0; i < cols_info.length; i++) {
            //      var config = cols_info[i];

            //      var factory = create_factory (config.property_name, config.property_type);
            //      var column = new Gtk.ColumnViewColumn (config.title, factory);
            //      column.expand = config.expand;

            //      facts.add (factory);
            //      view.append_column (column);
            //  }
        }

        //  public Gtk.SignalListItemFactory create_factory () {
        //      //  var factory = new Gtk.BuilderListItemFactory ();

        //  }


        [GtkChild]
        private unowned Gtk.ColumnView columns;
        [GtkChild]
        private unowned Gtk.ColumnView indexes;
        [GtkChild]
        private unowned Gtk.ColumnView foreign_key;
    }

    public struct ColumnInfo {
        string title;
        string property_name;
        Type property_type;
        bool expand;
    }
}