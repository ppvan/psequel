namespace Psequel {
    public abstract class BaseViewModel : Object {

        public const string CONNECTION_VIEW = "connection-view";
        public const string QUERY_VIEW = "query-view";

        public signal void navigate_to (string view);


        protected BaseViewModel () {
            Object ();
        }
    }
}