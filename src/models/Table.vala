namespace Psequel {

    /** Table object in database, hold meta-data about the table */
    public class Table : Object {

        public Schema schema { get; construct; }
        public string name { get; set; }
        public List<Column> columns { get; owned set; default = new List<Column> ();}
        public List<Index> indexes { get; owned set; default = new List<Index> (); }
        public List<ForeignKey> foreign_keys { get; owned set; default = new List<ForeignKey> ();}

        public Table (Schema schema) {
            Object (schema: schema);
        }
    }

    public class View : Object {
        public Schema schema { get; construct; }
        public string name { get; set; }
        public List<Column> columns { get; owned set; default = new List<Column> ();}
        public List<Index> indexes { get; owned set; default = new List<Index> ();}

        public View (Schema schema) {
            Object (schema: schema);
        }
    }
}