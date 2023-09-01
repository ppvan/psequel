using GtkSource;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-editor.ui")]
    public class QueryEditor : Adw.Bin {


        const string LIGHT_TAG = "query-block-light";
        const string DARK_TAG = "query-block-dark";

        delegate void ChangeStateFunc (SimpleAction action, Variant? new_state);

        public ExportService export_service {get; set;}
        public QueryViewModel query_viewmodel { get; set; }


        public QueryHistoryViewModel query_history_viewmodel { get; set; }
        public Query? selected_query { get; set; }



        private GtkSource.Completion completion;
        private SQLCompletionProvider provider;


        private LanguageManager lang_manager;
        private StyleSchemeManager style_manager;

        public class QueryEditor () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            this.export_service = autowire<ExportService> ();
            this.query_viewmodel = autowire<QueryViewModel> ();
            this.query_history_viewmodel = autowire<QueryHistoryViewModel> ();

            default_setttings ();
            selection_model.bind_property ("selected", this, "selected-query", BindingFlags.BIDIRECTIONAL, from_selected, to_selected);
            spinner.bind_property ("spinning", run_query_btn, "sensitive", BindingFlags.INVERT_BOOLEAN);

            buffer.changed.connect (highlight_current_query);
            buffer.cursor_moved.connect (highlight_current_query);

            create_action_group ();
            setup_paned (paned);
        }


        [GtkCallback]
        private void run_query_cb (Gtk.Button btn) {
            query_viewmodel.run_selected_query.begin ();
        }

        [GtkCallback]
        private void on_clear_history (Gtk.Button btn) {
            query_history_viewmodel.clear_history.begin ();
            popover.hide ();
        }

        [GtkCallback]
        private void on_query_history_exec (Gtk.ListView view, uint pos) {

            var history_query = (Query)selection_model.get_item (pos);

            debug ("%p", history_query);
            debug ("%u", selection_model.get_n_items ());
            debug ("%u %i", pos, query_history_viewmodel.query_history.size);
            //  debug ("History activated, exec: %s", history_query.sql);
            //  query_history_viewmodel.exec_history.begin (history_query);

            //  var text = history_query.sql ?? "";
            //  clear_and_insert (buffer, text);

            //  popover.hide ();
        }

        /** Clear and insert insteal of manipulate .text to keep undo possible */
        private void clear_and_insert (Gtk.TextBuffer buf, string text) {
            Gtk.TextIter iter1;
            buffer.get_start_iter (out iter1);

            Gtk.TextIter iter2;
            buffer.get_end_iter (out iter2);

            buffer.delete_range (iter1, iter2);

            // buffer.insert (ref iter1, );
            buffer.insert_at_cursor (text, text.length);
        }

        private void default_setttings () {

            lang_manager = LanguageManager.get_default ();
            style_manager = StyleSchemeManager.get_default ();

            completion = editor.get_completion ();
            completion.select_on_show = true;
            completion.page_size = 8;
            provider = new SQLCompletionProvider ();
            completion.add_provider (provider);

            var lang = lang_manager.get_language ("sql");
            buffer.language = lang;

            var light_tag = new Gtk.TextTag (LIGHT_TAG);
            light_tag.background_rgba = { 237 / 255f, 255 / 255f, 255 / 255f, 0.8f };

            var dark_tag = new Gtk.TextTag (DARK_TAG);
            dark_tag.background_rgba = { 55 / 255f, 55 / 255f, 55 / 255f, 0.8f };
            // tag.background = "sidebar_backdrop_color";
            // rgba(52, 73, 94,1.0)
            // rgb(237, 255, 255)
            buffer.tag_table.add (light_tag);
            buffer.tag_table.add (dark_tag);

            Application.app.style_manager.bind_property ("dark", buffer, "style_scheme", BindingFlags.SYNC_CREATE, (binding, from, ref to) => {
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

        private void highlight_current_query () {

            var stmts = PGQuery.split_statement (buffer.text);
            this.clear_highlight ();
            stmts.foreach ((token) => {

                var start = token.location;
                var end = token.location + token.statement.length;

                // debug ("[%d, %d], %s", token.location, token.end, token.value);

                Gtk.TextIter iter1;
                Gtk.TextIter iter2;

                // buffer.get_start_iter (out iter1);
                // buffer.get_end_iter (out iter2);
                // buffer.remove_tag_by_name (TAG_NAME, iter1, iter2);

                buffer.get_iter_at_offset (out iter1, start);
                buffer.get_iter_at_offset (out iter2, end);

                if (start < buffer.cursor_position && buffer.cursor_position <= end + 1) {
                    
                    if (Application.app.style_manager.dark) {
                        buffer.apply_tag_by_name (DARK_TAG, iter1, iter2);
                    } else {
                        buffer.apply_tag_by_name (LIGHT_TAG, iter1, iter2);
                    }

                    // Important
                    query_viewmodel.selected_query_changed (token.statement);
                } else {
                    buffer.remove_tag_by_name (DARK_TAG, iter1, iter2);
                    buffer.remove_tag_by_name (LIGHT_TAG, iter1, iter2);
                }
            });
        }

        private inline void clear_highlight () {
            Gtk.TextIter start;
            Gtk.TextIter end;

            buffer.get_start_iter (out start);
            buffer.get_end_iter (out end);
            buffer.remove_tag_by_name (DARK_TAG, start, end);
            buffer.remove_tag_by_name (LIGHT_TAG, start, end);
        }

        private void create_action_group () {

            var group = new SimpleActionGroup ();
            this.insert_action_group ("editor", group);

            var auto_uppercase = boolean_state_factory ("auto-uppercase", change_autouppercase);

            var auto_exec_history = boolean_state_factory ("auto-exec-history", change_auto_exec_history);

            group.add_action (auto_uppercase);
            group.add_action (auto_exec_history);

            this.insert_action_group ("editor", group);
        }

        private SimpleAction boolean_state_factory (string name, owned ChangeStateFunc func) {
            bool init = Application.settings.get_boolean (name);

            var action = new SimpleAction.stateful (name, null, new Variant.boolean (init));
            action.activate.connect (toggle_boolean);
            action.change_state.connect ((owned)func);

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

        private void change_auto_exec_history (SimpleAction action, Variant? new_state) {
            debug ("change_auto_exec_history");
            bool auto_exec = new_state.get_boolean ();

            action.set_state (new_state);
            Application.settings.set_boolean ("auto-exec-history", auto_exec);
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

        [GtkCallback]
        private void on_export_csv (Gtk.Button btn) {
            export_to_csv_file.begin ();
        }

        private async void export_to_csv_file (string title = "Open File") {
            var filter = new Gtk.FileFilter ();
            //  filter.add_pattern ("*.csv");
            filter.add_mime_type ("text/csv");
            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (filter);

            var window = (Window) get_parrent_window (this);

            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = GLib.File.new_for_path (Environment.get_home_dir ()),
                title = title,
                default_filter = filter,
                filters = filters
            };

            try {
                var dest = yield file_dialog.save (window, null);
                yield export_service.export_csv (dest, query_history_viewmodel.current_relation);

            } catch (GLib.Error err) {
                debug (err.message);

                var toast = new Adw.Toast (err.message) {
                    timeout = 3,
                };

                window.add_toast (toast);
            }
        }

        [GtkChild]
        private unowned GtkSource.View editor;

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