using Postgres;
using Gee;

namespace Psequel {

    public delegate Relation.Row TransFormsFunc (Relation.Row row);

    public class Relation : Object {

        public int rows { get; private set; }
        public int cols { get; private set; }

        private ArrayList<Row> data;
        private ArrayList<string> headers;

        public Relation (owned Result res) {
            Object ();
            load_data ((owned) res);
        }

        private Relation.from_data (ArrayList<string> headers, ArrayList<Row> data) {
            this.headers = headers;
            this.data = data;
            this.rows = data.size;
            this.cols = headers.size;
        }

        private void load_data (owned Result result) {
            assert_nonnull (result);

            rows = result.get_n_tuples ();
            cols = result.get_n_fields ();

            this.headers = new ArrayList<string> ();
            for (int i = 0; i < cols; i++) {
                headers.add (result.get_field_name (i));
            }

            this.data = new ArrayList<Row> ();

            for (int i = 0; i < rows; i++) {
                data.add (new Row ());

                for (int j = 0; j < cols; j++) {
                    data[i].add_field (result.get_value (i, j));
                }
            }
        }

        public Relation transform (ArrayList<string> new_headers, TransFormsFunc func) {

            var new_rows = new ArrayList<Relation.Row> ();

            assert_nonnull (this.data);
            foreach (var row in this.data) {
                new_rows.add (func (row));
            }

            return new Relation.from_data (new_headers, new_rows);
        }

        public string get_header (int index) {
            if (index >= cols) {
                return "";
            }

            return headers.get (index);
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

            public string ahihi {get; set;}

            private ArrayList<string> data;

            public int size {
                get { return data.size; }
            }

            internal Row () {
                this.data = new ArrayList<string> ();
                ahihi = "Hello";
            }

            public void add_field (string item) {
                data.add (item);
            }

            public void insert_field (int index, string item) {
                data.insert (index, item);
            }

            public void remove_at (int index) {
                assert (index < size);
                assert (index >= 0);

                data.remove_at (index);
            }

            public new string? @get (int index) {
                if (index >= size) {
                    return null;
                }
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
    }
}