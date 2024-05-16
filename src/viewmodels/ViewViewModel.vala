namespace Psequel {
/* View here is database view (virtual tables), not UI */
public class ViewViewModel : BaseViewModel {
    public ObservableList <View> views { get; set; default = new ObservableList <View> (); }
    public View ?selected_view { get; set; }

    public Schema schema { get; private set; }
    public SQLService sql_service { get; private set; }


    public ViewViewModel(SQLService service) {
        base();
        this.sql_service = service;
        this.notify["selected-view"].connect(() => {
                EventBus.instance().selected_view_changed(selected_view);
            });

        EventBus.instance().schema_changed.connect((schema) => {
                views.clear();
                load_views.begin(schema);
            });
    }

    public void select_view(View ?view) {
        if (view == null)
        {
            return;
        }


        debug("selecting view %s", view.name);
        selected_view = view;
    }

    public void select_index(int index) {
        if (index < 0 || index >= views.size)
        {
            return;
        }

        debug("selecting view %s", views[index].name);
        selected_view = views[index];
    }

    public bool is_view(string view_name) {
        return views.find((view) => {
            return view.name == view_name;
        }) != null;
    }

    public async string get_viewdef(string view_name) {
        debug("loading views");
        var query = new Query.with_params(VIEW_DEF, { view_name });
        try {
            var relation = yield sql_service.exec_query_params(query);

            if (relation.rows > 0)
            {
                return(relation[0][0]);
            }
        } catch (PsequelError err) {
            debug("Error: " + err.message);
        }

        return("Error: can't get view def for " + view_name);
    }

    private async void load_views(Schema schema) throws PsequelError {
        debug("loading views");
        var query    = new Query.with_params(VIEW_LIST, { schema.name });
        var relation = yield sql_service.exec_query_params(query);

        foreach (var item in relation)
        {
            var view = new View(schema);
            view.name = item[0];
            views.append(view);
        }

        debug("%d views loaded", views.size);
    }

    public const string VIEW_LIST = """
        SELECT table_name FROM INFORMATION_SCHEMA.views WHERE table_schema = $1;
        """;

    public const string VIEW_DEF = """
        SELECT pg_get_viewdef($1);
        """;
}
}
