using Postgres;
using Gee;

namespace Psequel {
    public class Table : Object {

        // Keep references to result so data is not destroy.
        private Result result;
        public int rows { get; private set; }
        private int cols { get; private set; }

        private Header header { get; private set; }
        public ArrayList<Row> data;

        public Table (owned Result res) {
            Object ();
            result = (owned) res;
            load_data ();
        }

        private void load_data () {
            assert_nonnull (result);

            rows = result.get_n_tuples ();
            cols = result.get_n_fields ();

            header = new Header ();
            for (int i = 0; i < cols; i++) {
                header.add_field (result.get_field_name (i));
            }

            this.data = new ArrayList<Row> ();

            for (int i = 0; i < rows; i++) {
                data.add (new Row (header));
                for (int j = 0; j < cols; j++) {
                    data[i].add_field (result.get_value (i, j));
                }
            }
        }

        public string to_string () {
            return @"Table ($rows x $cols)";
        }

        public string name { get; set; }

        public Iterator<Row> iterator () {
            return data.iterator ();
        }

        public new Row @get (int index) {
            return data.get (index);
        }

        /**
         * Helper class for ease of use with Table. DO NOT use it outside of Table class.
         */
        public class Row : Object {


            private ArrayList<unowned string> data;
            private Header header;

            public int size {
                get { return data.size; }
            }

            internal Row (Header header) {
                this.data = new ArrayList<unowned string> ();
                this.header = header;
            }

            public void add_field (string item) {
                assert (data.size < header.size);
                data.add (item);
            }

            public new unowned string @get (int index) {
                return data.get (index);
            }

            public string to_string () {

                var builder = new StringBuilder ("");
                for (int i = 0; i < data.size; i++) {
                    builder.append_printf ("%s\t\t", data[i]);
                }

                return builder.free_and_steal ();
            }
        }

        /**
         * Helper class for ease of use with Table. DO NOT use it outside of Table class.
         */
        public class Header : Object {
            private ArrayList<unowned string> data;

            public int size {
                get { return data.size; }
            }

            internal Header () {
                this.data = new ArrayList<unowned string> ();
            }

            public void add_field (string item) {
                data.add (item);
            }

            public new unowned string @get (int index) {
                return data.get (index);
            }

            public string to_string () {
                var row_data = data.fold<string> ((seed, item) => seed + item.dup () + ",", "");
                return row_data;
            }
        }
    }
}