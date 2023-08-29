namespace Psequel {

    public class EventManager : Object {
        private List<EventTarget> targets;

        private class EventTarget {
            public string event_type;
            public Observer observer;
        }

        public new void notify (string event_type, Object data) {
            foreach (EventTarget target in targets) {
                if (target.event_type == event_type) {
                    Event event = new Event (event_type, data);
                    target.observer.update (event);
                }
            }
        }

        public EventManager () {
            Object();
            targets = new List<EventTarget>();
        }


        public void subcribe (string event_type, Observer observer) {
            EventTarget target = new EventTarget();
            target.event_type = event_type;
            target.observer = observer;

            targets.append (target);
        }
    }

    public class Event : Object {
        public const string SCHEMA_CHANGED = "schema-changed";
        public const string SELECTED_TABLE_CHANGED = "selected-table-changed";
        public const string SELECTED_VIEW_CHANGED = "selected-view-changed";
        public const string ACTIVE_CONNECTION = "active-connection";
        public string type;
        public Object data;

        public Event (string type, Object data) {
            base();
            this.type = type;
            this.data = data;
        }
    }

    public interface Observer : Object {
        public abstract void update(Event event);
    }
}