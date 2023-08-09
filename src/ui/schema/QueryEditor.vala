using GtkSource;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-editor.ui")]
    public class QueryEditor : Adw.Bin {

        delegate void ChangeStateFunc (SimpleAction action, Variant? new_state);

        public QueryViewModel query_viewmodel { get; set; }

        public Query? selected_query { get; set; }


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

            selection_model.bind_property ("selected", this, "selected-query", BindingFlags.BIDIRECTIONAL, from_selected, to_selected);

            spinner.bind_property ("spinning", run_query_btn, "sensitive", BindingFlags.INVERT_BOOLEAN);


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

            var auto_uppercase = boolean_state_factory ("auto-uppercase", change_autouppercase);

            var auto_completion = boolean_state_factory ("auto-completion", change_autocompletion);

            var auto_exec_history = boolean_state_factory ("auto-exec-history", change_auto_exec_history);

            group.add_action (auto_uppercase);
            group.add_action (auto_completion);
            group.add_action (auto_exec_history);

            this.insert_action_group ("editor", group);
        }

        private SimpleAction boolean_state_factory (string name, ChangeStateFunc func) {
            bool init = Application.settings.get_boolean (name);

            var action = new SimpleAction.stateful (name, null, new Variant.boolean (init));
            action.activate.connect (toggle_boolean);
            action.change_state.connect (func);

            return action;
        }

        private void toggle_boolean (Action action, Variant? parameter) {
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

        private void change_autocompletion (SimpleAction action, Variant? new_state) {
            debug ("Change autocompletion");
            bool autocompletion = new_state.get_boolean ();

            action.set_state (new_state);
            Application.settings.set_boolean ("auto-completion", autocompletion);
        }

        private void change_auto_exec_history (SimpleAction action, Variant? new_state) {
            debug ("change_auto_exec_history");
            bool auto_exec = new_state.get_boolean ();

            action.set_state (new_state);
            Application.settings.set_boolean ("auto-exec-history", auto_exec);
        }

        [GtkCallback]
        private void run_query_cb (Gtk.Button btn) {

            var text = buffer.text.strip ();
            debug ("Exec query: %s", text);

            query_viewmodel.run_current_query.begin ();
        }

        [GtkCallback]
        private void on_listview_activate (Gtk.ListView view, uint pos) {
            query_viewmodel.exec_history.begin (selected_query);

            buffer.text = selected_query?.sql;
            popover.hide ();
        }

        private bool from_selected (Binding binding, Value from, ref Value to) {
            uint pos = from.get_uint ();

            if (pos != Gtk.INVALID_LIST_POSITION) {
                to.set_object (selection_model.get_item (pos));
            }

            return true;
        }

        private bool to_selected (Binding binding, Value from, ref Value to) {

            Query query = (Query) from.get_object ();
            for (uint i = 0; i < selection_model.get_n_items (); i++) {
                if (selection_model.get_item (i) == query) {
                    to.set_uint (i);
                    return true;
                }
            }

            to.set_uint (Gtk.INVALID_LIST_POSITION);

            return true;
        }

        // [GtkChild]
        // private unowned GtkSource.View editor;

        [GtkChild]
        private unowned Gtk.Button run_query_btn;

        [GtkChild]
        private unowned Gtk.Spinner spinner;


        [GtkChild]
        private unowned GtkSource.Buffer buffer;

        [GtkChild]
        private unowned Gtk.Paned paned;

        [GtkChild]
        private unowned Gtk.SingleSelection selection_model;

        [GtkChild]
        private unowned Gtk.Popover popover;
    }
}