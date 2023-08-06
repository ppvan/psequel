using Gee;

namespace Psequel {

    public class ObservableArrayList<T>: ListModel, Object {

        private ArrayList<T> _data;

        public int size { get { return _data.size; } }

        public ObservableArrayList () {
            _data = new ArrayList<T> ();
        }

        public GLib.Object? get_item (uint position) {
            return get_object (position);
        }

        public GLib.Type get_item_type () {
            return _data.element_type;
        }

        public uint get_n_items () {
            return _data.size;
        }

        public GLib.Object? get_object (uint position) {
            int index = (int) position;
            if (index >= _data.size) {
                return null;
            }

            return (Object) _data.get (index);
        }

        public new T @get (int index) {
            return _data.get (index);
        }

        public void add (T item) {
            _data.add (item);
            items_changed (size - 1, 0, 1);
        }

        public void batch_add (Iterator<T> items) {
            var last = _data.size;
            _data.add_all_iterator (items);
            // model.batch_add (relation.iterator ());
            items_changed (last, 0, size - last);
        }

        public void remove_at (int index) {
            _data.remove_at (index);
            items_changed (index, 1, 0);
        }

        public void clear () {
            var back_up = this.size;
            _data.clear ();
            items_changed (0, back_up, 0);
        }

        public Iterator<T> iterator () {
            return _data.iterator ();
        }

        public void insert (T item, int pos) {
            _data.insert (pos, item);
            items_changed (pos, 0, 1);
        }
    }
}