namespace Psequel {
public class NavigationService : Object {
    public const string CONNECTION_VIEW = "connection-view";
    public const string QUERY_VIEW      = "query-view";
    public const string[] VIEW_NAMES    = { CONNECTION_VIEW, QUERY_VIEW };

    public string current_view { get; set; default = CONNECTION_VIEW; }

    public NavigationService() {
    }

    public void navigate(string view_name) {
        if (view_name == current_view)
        {
            return;
        }

        for (int i = 0; i < VIEW_NAMES.length; i++)
        {
            if (VIEW_NAMES[i] == view_name)
            {
                debug("Navigating to " + view_name);
                current_view = view_name;
                return;
            }
        }
    }
}
}
