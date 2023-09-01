namespace Psequel {
    public class SQLCompletionProvider : Object, GtkSource.CompletionProvider {
        private CompleterService completer;
        private Gtk.FilterListModel model;
        private Gtk.StringFilter filter;

        private SchemaContext ctx;


        private SchemaViewModel schema_viewmodel;
        public SQLCompletionProvider () {
            base ();
            this.schema_viewmodel = autowire<SchemaViewModel> ();
            this.completer = autowire<CompleterService> ();
            this.ctx = new SchemaContext ();

            // static_candidates = new List<Candidate> ();
            // for (int i = 0; i < PGListerals.KEYWORDS.length; i++) {
            // static_candidates.append (new Candidate (PGListerals.KEYWORDS[i], "KEYWORD"));
            // }

            // for (int i = 0; i < PGListerals.FUNCTIONS.length; i++) {
            // static_candidates.append (new Candidate (PGListerals.FUNCTIONS[i], "FUNCTION"));
            // }

            // for (int i = 0; i < PGListerals.DATATYPES.length; i++) {
            // static_candidates.append (new Candidate (PGListerals.DATATYPES[i], "DATATYPE"));
            // }

            // for (int i = 0; i < PGListerals.RESERVED.length; i++) {
            // static_candidates.append (new Candidate (PGListerals.RESERVED[i], "RESERVED"));
            // }

            // this.notify["query-viewmodel"].connect (() => {

            // dynamic_candidates = new List<Model> ();
            // query_viewmodel.current_schema.tables.foreach ((table) => {
            // dynamic_candidates.append (new Model (table.name, "TABLE"));
            // });
            // query_viewmodel.current_schema.views.foreach ((view) => {
            // dynamic_candidates.append (new Model (view.name, "VIEW"));
            // });
            // });

            var expression = new Gtk.PropertyExpression (typeof (Candidate), null, "value");
            filter = new Gtk.StringFilter (expression);
            filter.match_mode = Gtk.StringFilterMatchMode.PREFIX;

            model = new Gtk.FilterListModel (null, filter);
        }

        public void activate (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal) {
            var model = (Candidate) proposal;
            var buf = context.get_buffer ();
            Gtk.TextIter start, end;

            last_word (buf, out start, out end);

            buf.delete_range (start, end);
            buf.insert_at_cursor (model.value, model.value.length);
            // buf.insert (ref iter, model.value, model.value.length);
        }

        public void display (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal, GtkSource.CompletionCell cell) {

            var candidate = (Candidate) proposal;
            switch (cell.column) {
            // name
            case GtkSource.CompletionColumn.TYPED_TEXT:
                cell.text = candidate.value;
                break;

            // group
            case GtkSource.CompletionColumn.AFTER:
                cell.text = candidate.group;
                break;
            // case GtkSource.CompletionColumn.DETAILS:
            // cell.text = "DETAILS";
            // break;
            // case GtkSource.CompletionColumn.COMMENT:
            // cell.text = "COMMENT";
            // break;
            // case GtkSource.CompletionColumn.ICON:
            // cell.text = "ICON";
            // break;
            // case GtkSource.CompletionColumn.BEFORE:
            // cell.text = "BEFORE";
            // break;
            default: break;
            }
        }

        public async GLib.ListModel populate_async (GtkSource.CompletionContext context, GLib.Cancellable? cancellable) {

            var word = last_word (context.get_buffer ());
            var candidates = new ObservableList<Candidate> ();

            candidates.append_all (completer.get_suggestions (this.ctx, word));
            model.model = candidates;

            return model;
        }

        public void refilter (GtkSource.CompletionContext context, GLib.ListModel _model) {
            var word = last_word (context.get_buffer ());
            filter.search = word;
            filter.changed (Gtk.FilterChange.MORE_STRICT);
        }

        private string last_word (GtkSource.Buffer buf, out Gtk.TextIter start = null, out Gtk.TextIter end = null) {
            Gtk.TextIter iter;
            buf.get_iter_at_offset (out iter, buf.cursor_position);

            start = iter;
            end = iter;

            start.backward_word_start ();
            end.forward_word_end ();

            return buf.get_text (start, end, false);
        }
    }
}