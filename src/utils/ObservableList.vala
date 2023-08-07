
namespace Psequel {
    /** A list that's notify item-changed when there's changes to the list itself. */
    public class ObservableList<T>: Object, ListModel {

        private ListStore _data;

        public int size {get; private set;}

        public delegate void ForeachFunc<T> (T item);

        public ObservableList () {
            base ();
            this._data = new ListStore (typeof (T));

            // Forward item changed event.
            this._data.items_changed.connect (this.items_changed);
            this._data.items_changed.connect (() => {
                this.size = (int)this._data.get_n_items ();
            });
        }

        public new T @get (int i) {
            return (T)_data.get_item ((uint)i);
        }

        public void clear () {
            _data.remove_all ();
        }

        public void append_all (List<T> items) {
            items.foreach ((item) => _data.append ((Object)item));
        }

        public void append (T item) {
            _data.append ((Object)item);
        }

        public void extend (List<T> items) {
            items.foreach ((item) => _data.append ((Object)item));
        }

        public void remove (T item) {
            uint pos;
            _data.find ((Object)item, out pos);

            _data.remove (pos);
        }

        public void remove_at (uint position) {
            _data.remove (position);
        }

        public void insert (uint pos, Connection conn) {
            _data.insert (pos, conn);
        }

        public uint indexof (Connection conn) {
            uint pos;
            _data.find (conn, out pos);

            return pos;
        }

        public void @foreach (ForeachFunc<T> func) {
            for (uint i = 0; i < this.size; i++) {
                func (_data.get_item (i));
            }
        }

        public GLib.Object? get_item (uint position) {
            return _data.get_item (position);
        }
        public GLib.Type get_item_type () {
            return _data.get_item_type ();
        }

        public uint get_n_items () {
            return _data.get_n_items ();
        }
    }
}