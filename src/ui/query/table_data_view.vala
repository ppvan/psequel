using Gee;
namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-data-view.ui")]
    public class TableData : Gtk.Box {

        public Window window {get; set;}
        private unowned WindowSignals signals;
        private QueryService query_service;

        private ObservableArrayList<Relation.Row> model;

        public int query_limit { get; set; }

        public Schema schema { get; set; }
        public string tbname { get; private set; }
        public int current_page { get; private set; default = 0; }

        public TableData () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            model = new ObservableArrayList<Relation.Row> ();

            var setting = ResourceManager.instance ().settings;
            setting.bind ("query-limit", this, "query-limit", SettingsBindFlags.DEFAULT);

            ResourceManager.instance ().app_signals.window_ready.connect (setup_signals);
        }


        public async void load_data (string schema, string table_name, int page = 0, string where = "") {

            var offset = current_page * query_limit;

            try {
                query_results.show_loading ();

                var relation = yield query_service.select (schema, table_name, offset, query_limit, where);

                query_results.show_result (relation);

                update_status_label (relation);
                update_pagination_btn (relation);
            } catch (PsequelError err) {
                query_results.show_error (err);
            }
        }

        private void update_pagination_btn (Relation relation) {
            if (relation.rows < query_limit) {
                right_page.sensitive = false;
            } else {
                right_page.sensitive = true;
            }

            if (current_page > 0) {
                left_page.sensitive = true;
            } else {
                left_page.sensitive = false;
            }
        }

        private void update_status_label (Relation relation) {
            uint begin = query_limit * current_page + 1;
            uint end = begin + relation.rows - 1;

            status_label.label = @"Rows $begin - $end";
        }

        private void setup_signals () {

            // signals can only be connected after the window is ready.
            // because widget access window to get signals.
            ResourceManager.instance ().app_signals.window_ready.connect (() => {
                //  signals = window.signals;

                signals.table_selected_changed.connect ((tbname) => {
                    this.tbname = tbname;
                    this.filter_entry.set_text ("");
                    load_data.begin (schema.name, tbname);
                });

                signals.view_selected_changed.connect ((vname) => {
                    this.tbname = vname;
                    this.filter_entry.set_text ("");
                    load_data.begin (schema.name, vname);
                });

                signals.schema_changed.connect ((schema) => {
                    this.schema = schema;
                });

                //  query_service = window.query_service;
            });
        }


        [GtkCallback]
        private void filter_query (Gtk.Button btn) {
            var where_clause = filter_entry.get_text ();

            if (!where_clause.up ().has_prefix ("WHERE")) {
                var dialog = create_dialog ("Filter Failed", "WHERE clause should starts with 'WHERE'");
                dialog.present ();
            } else {
                load_data.begin (schema.name, tbname, current_page, where_clause);
            }
        }

        [GtkCallback]
        private void on_entry_activated (Gtk.Entry entry) {
            filter_btn.clicked ();
        }

        [GtkCallback]
        private void load_next_page (Gtk.Button btn) {
            load_data.begin (schema.name, tbname, ++current_page);
        }

        [GtkCallback]
        private void load_previous_page (Gtk.Button btn) {
            load_data.begin (schema.name, tbname, --current_page);
        }

        [GtkCallback]
        private void reload_data (Gtk.Button btn) {
            load_data.begin (schema.name, tbname, current_page);
        }

        public void table_double_clicked () {
            debug ("Activated");
        }

        [GtkChild]
        private unowned QueryResults query_results;

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