namespace Psequel{
    public class ExportService : Object {

        public const string DELIMETER = ",";
        public const string NEWLINE = "\n";

        public ExportService () {
        }

        // Implement accordding to https://en.wikipedia.org/wiki/Comma-separated_values?useskin=vector#Basic_rules
        public async void export_csv (File dest, Relation relation) throws PsequelError {

            string[] rows = new string[relation.rows];
            for (int i = 0; i < relation.rows; i++) {
                string[] cols = new string[relation.cols];
                var row = relation[i];
                for (int j = 0; j < relation.cols; j++) {
                    cols[j] = quote (row[j]);

                    debug (cols[j]);
                }

                rows[i] = string.joinv (DELIMETER, cols);
            }
            
            var bytes = new Bytes.take (string.joinv (NEWLINE, rows).data);

            try {
                yield dest.replace_contents_bytes_async (bytes, null, false, FileCreateFlags.PRIVATE, null, null);
            } catch (GLib.Error err) {
                throw new PsequelError.EXPORT_ERROR(err.message);
            }
        }

        private string quote (string str) {
            if (str.contains (DELIMETER)) {
                return @"\"$(str)\"";
            }

            return str;
        } 
    }
}