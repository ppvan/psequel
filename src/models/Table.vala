namespace Psequel {
public abstract class BaseTable : Object {
    public Schema schema { get; construct; }
    public string name { get; set; }
}


/** Table object in database, hold meta-data about the table */
public sealed class Table : BaseTable {
    public Vec <Column> columns { get; owned set; default = new Vec <Column> (); }
    public Vec <Index> indexes { get; owned set; default = new Vec <Index> (); }
    public Vec <ForeignKey> foreign_keys { get; owned set; default = new Vec <ForeignKey> (); }
    public Vec <PrimaryKey> primaty_keys { get; owned set; default = new Vec <PrimaryKey> (); }
    public int64 row_count {get; set;}

    public Table(Schema schema) {
        Object(schema: schema);
    }
}

public sealed class View : BaseTable {
    public List <Column> columns { get; owned set; default = new List <Column> (); }
    public List <Index> indexes { get; owned set; default = new List <Index> (); }

    public View(Schema schema) {
        Object(schema: schema);
    }
}
}
