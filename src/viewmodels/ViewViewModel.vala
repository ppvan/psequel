namespace Psequel {
/* View here is database view (virtual tables), not UI */
public class ViewViewModel : BaseViewModel, Observer {
    public ObservableList <View> views { get; set; default = new ObservableList <View> (); }
    public View ?selected_view { get; set; }

    public Schema schema { get; private set; }
    public SQLService sql_service { get; private set; }


    public ViewViewModel(SQLService service) {
        base();
        this.sql_service = service;
        this.notify["selected-view"].connect(() => {
                this.emit_event(Event.SELECTED_VIEW_CHANGED, selected_view);
            });
    }

    public void update(Event event) {
        if (event.type == Event.SCHEMA_CHANGED)
        {
            schema = (Schema)event.data;
            views.clear();
            load_views.begin(schema);
        }
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
}
}
