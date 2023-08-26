namespace Psequel {

    public class EventManager : Object {
        private List<EventTarget> targets;

        private class EventTarget {
            public string event_type;
            public Observer observer;
        }

        public new void notify (string event_type, Object data) {
            foreach (EventTarget target in targets) {
                if (target.event_type == event_type)
                    target.observer.update (data);
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

    public interface Observer : Object {
        public abstract void update(Object data);
    }
}