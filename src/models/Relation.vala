using Postgres;

namespace Psequel {

    public delegate Relation.Row TransFormsFunc (Relation.Row row);

    /**
     * Relation class represent database "table".
     *
     * Not to confuse with Table class hold table info, this can hold any data return from database.
     */
    public class Relation : Object {

        public int rows { get; private set; }
        public int cols { get; private set; }
        /** Time of query created this relation in us */
        public int64 fetch_time {get; construct;}

        public string row_affected { get; private set; default = ""; }

        private List<Row> data;
        private List<string> headers;
        private List<Type> cols_type;

        public Relation (owned Result res) {
            Object (fetch_time: 0);
            load_data ((owned) res);
        }

        public Relation.with_fetch_time (owned Result res, int64 fetch_time) {
            Object (fetch_time: fetch_time);
            load_data ((owned) res);
        }

        public Type get_column_type (int index) {
            return this.cols_type.nth_data ((uint) index);
        }

        private void load_data (owned Result result) {
            assert_nonnull (result);

            rows = result.get_n_tuples ();
            cols = result.get_n_fields ();
            row_affected = result.get_cmd_tuples ();

            this.headers = new List<string> ();
            this.cols_type = new List<Type> ();
            for (int i = 0; i < cols; i++) {

                // Oid, should have enum for value type in VAPI but no.
                switch ((uint) result.get_field_type (i)) {
                case 20, 21, 23:
                    // int
                    this.cols_type.append (Type.INT64);
                    break;
                case 16:
                    // bool
                    this.cols_type.append (Type.BOOLEAN);
                    break;
                case 700, 701:
                    // real
                    this.cols_type.append (Type.DOUBLE);
                    break;
                case 25, 1043, 18, 19, 1700:
                    // string
                    this.cols_type.append (Type.STRING);
                    break;
                case 1114:
                    // timestamp
                    this.cols_type.append (Type.STRING);
                    break;
                case 1082:
                    // date
                    this.cols_type.append (Type.STRING);
                    break;

                default:
                    debug ("Programming errors, unhandled Oid: %u", (uint) result.get_field_type (i));
                    this.cols_type.append (Type.STRING);
                    break;
                    // assert_not_reached ();
                }

                headers.append (result.get_field_name (i));
            }

            this.data = new List<Row> ();

            for (int i = 0; i < rows; i++) {
                var row = new Row ();
                for (int j = 0; j < cols; j++) {
                    row.add_field (result.get_value (i, j));
                }
                data.append (row);
            }
        }

        public Relation.Iterator iterator () {
            return new Iterator (this);
        }

        public string get_header (int index) {
            if (index >= cols) {
                return "";
            }

            return headers.nth_data ((uint) index);
        }

        public string to_string () {
            return @"Table ($rows x $cols)";
        }

        public string name { get; set; }

        public new Row @get (int index) {
            return data.nth_data ((uint) index);
        }

        public class Iterator {

            private Relation relation;
            private int index;

            public Iterator (Relation relation) {
                this.relation = relation;
                this.index = 0;
            }

            public Relation.Row? next_value () {
                if (index == relation.rows) {
                    return null;
                }

                return relation[index++];
            }
        }

        /**
         * Helper class for ease of use with Relation.
         */
        public class Row : Object {


            private List<string> data;

            public int size {
                get { return (int) data.length (); }
            }

            internal Row () {
                this.data = new List<string> ();
            }

            public void add_field (string item) {
                data.append (item);
            }

            public void insert_field (int index, string item) {
                data.insert (item, index);
            }

            public void remove_at (int index) {
                assert (index < size);
                assert (index >= 0);

                data.remove (data.nth_data ((uint) index));
            }

            public new string ? @get (int index) {
                if (index >= size) {
                    return null;
                }
                return data.nth_data ((uint) index);
            }

            public string to_string () {

                var builder = new StringBuilder ("");
                data.foreach ((item) => {
                    builder.append_printf ("%s\t\t", item);
                });

                return builder.free_and_steal ();
            }
        }
    }
}