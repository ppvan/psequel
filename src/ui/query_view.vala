

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/query-view.ui")]
    public class QueryView : Adw.Bin {

        private unowned QueryService query_service;

        public QueryView () {
            Object ();
        }

        construct {
            query_service = ResourceManager.instance ().query_service;

        }
    }
}