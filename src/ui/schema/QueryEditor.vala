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

            create_action_group ();
            default_setttings ();

            buffer.notify["text"].connect (() => {
                query_viewmodel.query_string = buffer.text;
            });

            setup_paned (paned);

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

        private void create_action_group () {

            var group = new SimpleActionGroup ();

            var auto_uppercase = new SimpleAction.stateful ("auto-uppercase", null, new Variant.boolean (false));
            auto_uppercase.activate.connect (toggle_autouppercase);
            auto_uppercase.change_state.connect (change_autouppercase);

            var auto_completion = new SimpleAction.stateful ("auto-completion", null, new Variant.boolean (false));
            auto_completion.activate.connect (toggle_autocompletion);
            auto_completion.change_state.connect (change_autocompletion);

            group.add_action (auto_uppercase);
            group.add_action (auto_completion);

            this.insert_action_group ("editor", group);
        }

        private void toggle_autouppercase (Action action, Variant? parameter) {
            debug ("Activate autouppercase");
            Variant state = action.state;
            bool old_state = state.get_boolean ();
            bool new_state = !old_state;
            action.change_state (new_state);
        }

        private void change_autouppercase (SimpleAction action, Variant? new_state) {
            bool autouppercase = new_state.get_boolean ();
            debug ("Change auto uppercase");

            action.set_state (new_state);
            Application.settings.set_boolean ("auto-uppercase", autouppercase);
        }

        private void toggle_autocompletion (Action action, Variant? parameter) {
            debug ("Activate autocompletion");
            Variant state = action.state;
            bool old_state = state.get_boolean ();
            bool new_state = !old_state;
            action.change_state (new_state);
        }

        private void change_autocompletion (SimpleAction action, Variant? new_state) {
            debug ("Change autocompletion");
            bool autocompletion = new_state.get_boolean ();

            action.set_state (new_state);
            Application.settings.set_boolean ("auto-completion", autocompletion);
        }

        [GtkCallback]
        private void run_query_cb (Gtk.Button btn) {

            var text = buffer.text.strip ();
            debug ("Exec query: %s", text);

            query_viewmodel.run_current_query.begin ();
        }

        // [GtkChild]
        // private unowned GtkSource.View editor;

        [GtkChild]
        private unowned GtkSource.Buffer buffer;

        [GtkChild]
        private unowned Gtk.Paned paned;
    }
}