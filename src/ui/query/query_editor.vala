using GtkSource;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-editor.ui")]
    public class QueryEditor : Adw.Bin {

        private LanguageManager lang_manager;
        private StyleSchemeManager style_manager;


        public class QueryEditor () {
            Object ();
        }

        construct {
            debug ("Contruct view");

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

        [GtkChild]
        private unowned GtkSource.View editor;

        [GtkChild]
        private unowned GtkSource.Buffer buffer;
    }
}