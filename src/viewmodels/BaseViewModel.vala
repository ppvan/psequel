namespace Psequel {
    public abstract class BaseViewModel : Object {

        public const string CONNECTION_VIEW = "connection-view";
        public const string QUERY_VIEW = "query-view";

        public signal void navigate_to (string view);

        protected EventManager event_manager;

        protected BaseViewModel () {
            event_manager = new EventManager ();
            debug ("BaseViewModel created");
        }

        public void subcribe (string event_type, Observer observer) {
            event_manager.subcribe (event_type, observer);
        }

        protected void emit_event(string event_type, Object data) {
            event_manager.notify (event_type, data);
        }
    }
}