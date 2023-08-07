namespace Psequel {

    public abstract class BaseTable : Object {
        public Schema schema { get; construct; }
        public string name { get; set; }
    }


    /** Table object in database, hold meta-data about the table */
    public sealed class Table : BaseTable {

        public List<Column> columns { get; owned set; default = new List<Column> ();}
        public List<Index> indexes { get; owned set; default = new List<Index> (); }
        public List<ForeignKey> foreign_keys { get; owned set; default = new List<ForeignKey> ();}

        public Table (Schema schema) {
            Object (schema: schema);
        }
    }

    public sealed class View : BaseTable {

        public List<Column> columns { get; owned set; default = new List<Column> ();}
        public List<Index> indexes { get; owned set; default = new List<Index> ();}

        public View (Schema schema) {
            Object (schema: schema);
        }
    }
}