//  using Postgres;
//  using Gee;

//  namespace Psequel {

//      public delegate Relation.Row TransFormsFunc (Relation.Row row);

//      public class Relation : Object {

//          public int rows { get; private set; }
//          public int cols { get; private set; }

//          public string row_affected {get; private set; default = "";}

//          private ArrayList<Row> data;
//          private ArrayList<string> headers;
//          private ArrayList<Type> cols_type;

//          public Relation (owned Result res) {
//              Object ();
//              load_data ((owned) res);
//          }

//          private Relation.from_data (ArrayList<string> headers, ArrayList<Row> data) {
//              this.headers = headers;
//              this.data = data;
//              this.rows = data.size;
//              this.cols = headers.size;

//              this.cols_type = new ArrayList<Type> ();
//              // Fix me in the future
//              for (int i = 0; i < headers.size; i++) {
//                  this.cols_type.add (Type.STRING);
//              }
//          }

//          public Type get_column_type (int index) {
//              return this.cols_type[index];
//          }

//          private void load_data (owned Result result) {
//              assert_nonnull (result);

//              rows = result.get_n_tuples ();
//              cols = result.get_n_fields ();
//              row_affected = result.get_cmd_tuples ();

//              this.headers = new ArrayList<string> ();
//              this.cols_type = new ArrayList<Type> ();
//              for (int i = 0; i < cols; i++) {

//                  // Oid, should have enum for value type in VAPI but no.
//                  switch ((uint)result.get_field_type (i)) {
//                      case 20, 21, 23:
//                      // int
//                      this.cols_type.add (Type.INT64);
//                      break;
//                      case 16:
//                      // bool
//                      this.cols_type.add (Type.BOOLEAN);
//                      break;
//                      case 700, 701:
//                      // real
//                      this.cols_type.add (Type.DOUBLE);
//                      break;
//                      case 25, 1043, 18, 19, 1700:
//                      // string
//                      this.cols_type.add (Type.STRING);
//                      break;
//                      case 1114:
//                      // timestamp
//                      this.cols_type.add (Type.STRING);
//                      break;
//                      case 1082:
//                      // date
//                      this.cols_type.add (Type.STRING);
//                      break;

//                      default:
//                          debug ("Programming errors, unhandled Oid: %u", (uint)result.get_field_type (i));
//                          this.cols_type.add (Type.STRING);
//                      break;
//                          //  assert_not_reached ();
//                  }

//                  headers.add (result.get_field_name (i));
//              }

//              this.data = new ArrayList<Row> ();

//              for (int i = 0; i < rows; i++) {
//                  data.add (new Row ());

//                  for (int j = 0; j < cols; j++) {
//                      data[i].add_field (result.get_value (i, j));
//                  }
//              }
//          }

//          public Relation transform (ArrayList<string> new_headers, TransFormsFunc func) {

//              var new_rows = new ArrayList<Relation.Row> ();

//              assert_nonnull (this.data);
//              foreach (var row in this.data) {
//                  new_rows.add (func (row));
//              }

//              return new Relation.from_data (new_headers, new_rows);
//          }

//          public string get_header (int index) {
//              if (index >= cols) {
//                  return "";
//              }

//              return headers.get (index);
//          }

//          public string to_string () {
//              return @"Table ($rows x $cols)";
//          }

//          public string name { get; set; }

//          public Iterator<Row> iterator () {
//              return data.iterator ();
//          }

//          public new Row @get (int index) {
//              return data.get (index);
//          }


//          /**
//           * Helper class for ease of use with Table. DO NOT use it outside of Table class.
//           */
//          public class Row : Object {


//              private ArrayList<string> data;

//              public int size {
//                  get { return data.size; }
//              }

//              internal Row () {
//                  this.data = new ArrayList<string> ();
//              }

//              public void add_field (string item) {
//                  data.add (item);
//              }

//              public void insert_field (int index, string item) {
//                  data.insert (index, item);
//              }

//              public void remove_at (int index) {
//                  assert (index < size);
//                  assert (index >= 0);

//                  data.remove_at (index);
//              }

//              public new string? @get (int index) {
//                  if (index >= size) {
//                      return null;
//                  }
//                  return data.get (index);
//              }

//              public string to_string () {

//                  var builder = new StringBuilder ("");
//                  for (int i = 0; i < data.size; i++) {
//                      builder.append_printf ("%s\t\t", data[i]);
//                  }

//                  return builder.free_and_steal ();
//              }
//          }
//      }
//  }