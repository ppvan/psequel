namespace Psequel {

    /* View here is database view (virtual tables), not UI */
    public class ViewViewModel : BaseViewModel, Observer {
        public ObservableList<View> views { get; set; default = new ObservableList<View> (); }
        public View? current_view { get; set; }


        public Schema schema { get; private set; }
        public SQLService sql_service { get; private set; }

        public ViewStructureViewModel viewstructure_viewmodel {get; set;}
        public ViewDataViewModel viewdata_viewmodel {get; set;}


        public ViewViewModel (SQLService service) {
            base();
            this.sql_service = service;
            this.notify["current-view"].connect (() => {
                viewstructure_viewmodel = new ViewStructureViewModel (current_view);
                viewdata_viewmodel = new ViewDataViewModel (current_view, service);
            });
        }

        public void update (Event event) {
            if (event.type == Event.SCHEMA_CHANGED) {
                schema = (Schema) event.data;
                views.clear ();
                load_views.begin (schema);
            }
        }

        public void select_view (View view) {
            debug ("selecting view %s", view.name);
            current_view = view;
        }

        public void select_index (int index) {
            debug ("selecting view %s", views[index].name);
            current_view = views[index];
        }


        private async void load_views (Schema schema) throws PsequelError {
            debug ("loading views");
            var query = new Query.with_params (VIEW_LIST, { schema.name });
            var relation = yield sql_service.exec_query_params (query);

            foreach (var item in relation) {
                var view = new View (schema);
                view.name = item[0];
                views.append (view);
            }

            debug ("%d views loaded", views.size);
        }

        public const string VIEW_LIST = """
        SELECT table_name FROM INFORMATION_SCHEMA.views WHERE table_schema = $1;
        """;
    }
}