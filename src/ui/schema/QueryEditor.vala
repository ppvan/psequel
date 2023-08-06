using GtkSource;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-editor.ui")]
    public class QueryEditor : Adw.Bin {

        public QueryService query_service {get; set;}
        private LanguageManager lang_manager;
        private StyleSchemeManager style_manager;

        public class QueryEditor () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);

            lang_manager = LanguageManager.get_default ();
            style_manager = StyleSchemeManager.get_default ();

            default_setttings ();
        }

        void default_setttings () {

            var lang = lang_manager.get_language ("sql");
            buffer.language = lang;


            Adw.StyleManager.get_default ()
             .bind_property ("dark", buffer, "style_scheme", BindingFlags.SYNC_CREATE, (binding, from, ref to) => {
                var is_dark = from.get_boolean ();
                if (is_dark) {
                    var scheme = style_manager.get_scheme ("Adwaita-dark");
                    to.set_object (scheme);
                } else {
                    var scheme = style_manager.get_scheme ("Adwaita");
                    to.set_object (scheme);
                }

                return true;
            });
        }

        private async void run_query (string query) {
            try {
                query_results.show_loading ();
                int64 exec_time = 0;
                var relation = yield query_service.exec_query (query, out exec_time);

                query_results.show_result (relation);

                update_status (relation, exec_time);
            } catch (PsequelError err) {
                query_results.show_error (err);
            }
        }

        [GtkCallback]
        private void run_query_cb (Gtk.Button btn) {

            Gtk.TextIter start;
            Gtk.TextIter end;
            buffer.get_start_iter (out start);
            buffer.get_end_iter (out end);

            var text = buffer.get_text (start, end, true).strip ();
            debug ("Exec query: %s", text);

            run_query.begin (text);
        }

        private void update_status (Relation relation, int64 exec_time) {
            if (relation.row_affected == "") {
                row_affect.label = @"$(relation.rows) rows x $(relation.cols) cols";
            } else {
                row_affect.label = @"$(relation.row_affected) rows affected.";
            }

            query_time.label = @"$(exec_time / 1000) ms";
        }

        [GtkChild]
        private unowned QueryResults query_results;

        //  [GtkChild]
        //  private unowned GtkSource.View editor;

        [GtkChild]
        private unowned GtkSource.Buffer buffer;

        [GtkChild]
        private unowned Gtk.Label row_affect;


        [GtkChild]
        private unowned Gtk.Label query_time;
    }
}