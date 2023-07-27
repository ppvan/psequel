using GtkSource;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-editor.ui")]
    public class QueryEditor : Adw.Bin {

        public class QueryEditor () {
            Object ();
        }

        construct {
            debug ("Contruct view");

            var manager = LanguageManager.get_default ();
            var ids = manager.get_language_ids ();

            for (int i = 0; i < ids.length; i++) {
                var lang = manager.get_language (ids[i]);
                if (lang.id == "sql") {
                    buffer.language = lang;
                    break;
                }
            }
        }



        [GtkChild]
        private unowned GtkSource.View editor;

        [GtkChild]
        private unowned GtkSource.Buffer buffer;
    }
}