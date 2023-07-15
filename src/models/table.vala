using Postgres;
using Gee;

namespace Psequel {
    public class Table : Object {

        // Keep references to result so data is not destroy.
        private Result result;
        public int rows { get; private set; }
        private int cols { get; private set; }

        private ArrayList<unowned string> header { get; private set; }
        public ArrayList<ArrayList<unowned string>> data;

        public Table (owned Result res) {
            Object ();
            result = (owned) res;
            load_data ();
        }

        private void load_data () {
            assert_nonnull (result);

            rows = result.get_n_tuples ();
            cols = result.get_n_fields ();

            header = new ArrayList<unowned string> ();
            for (int i = 0; i < cols; i++) {
                header.add (result.get_field_name (i));
            }

            this.data = new ArrayList<ArrayList<unowned string>> ();

            for (int i = 0; i < rows; i++) {
                data.add (new ArrayList<unowned string> ());

                for (int j = 0; j < cols; j++) {
                    data[i].add (result.get_value (i, j));
                }
            }
        }

        public string to_string () {
            return @"Table ($rows x $cols)";
        }

        public string name { get; set; }
    }
}