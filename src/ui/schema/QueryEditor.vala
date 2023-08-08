using GtkSource;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-editor.ui")]
    public class QueryEditor : Adw.Bin {

        public QueryViewModel query_viewmodel { get; set; }
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

            buffer.notify["text"].connect (() => {
                query_viewmodel.query_string = buffer.text;
            });
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


        [GtkCallback]
        private void run_query_cb (Gtk.Button btn) {

            var text = buffer.text.strip ();
            debug ("Exec query: %s", text);

            query_viewmodel.run_current_query.begin ();
        }

        //  [GtkChild]
        //  private unowned GtkSource.View editor;

        [GtkChild]
        private unowned GtkSource.Buffer buffer;
    }
}