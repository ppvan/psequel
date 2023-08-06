namespace Psequel {

    /**
     * Carying schema info binded to widgets to update if needed.
     */
    public class Schema : Object {
        public string name { get; private set; }

        public List<Table> tables { get; owned set; }
        public List<View> views {get; owned set;}

        public Schema (string name) {
            Object ();
            this.name = name;
        }

        construct {
            tables = new List<Table> ();
            views = new List<View> ();
        }
    }

    public class BaseType : Object {
        public string name { get; set; default = ""; }
        public string schemaname { get; set; default = ""; }
        public string table {get; set; default = "";}

        public string to_string () {
            return @"$schemaname.$name";
        }
    }

    public class Index : BaseType {
        public bool unique { get; set; default = false; }
        public IndexType index_type { get; set; default = BTREE; }
        public string columns { get; set; default = ""; }
        public string size {get; set; default = "0 kB";}

        private string _indexdef;
        public string indexdef {
            get {
                return _indexdef;
            }
            set {
                this._indexdef = value ?? "";
                this.extract_info ();
            }
        }

        private void extract_info () {
            unique = indexdef.contains ("UNIQUE");

            //  Match the index type and column from indexdef, group 1 is type, group 2 is the column list.
            var regex = /USING (btree|hash|gist|spgist|gin|brin|[\w]+) \(([a-zA-Z1-9+\-*\/_, ()]+)\)/;
            MatchInfo match_info;
            if (regex.match (indexdef, 0, out match_info)) {
                index_type = IndexType.from_string (match_info.fetch (1));
                columns = match_info.fetch (2);
            } else {
                warning ("Regex not match: %s", indexdef);
                assert_not_reached ();
            }
        }

        // (btree|hash|gist|spgist|gin|brin|[\w]+
        public enum IndexType {
            BTREE,
            HASH,
            GIST,
            SPGIST,
            GIN,
            BRIN,
            USER_DEFINED;

            public string to_string () {
                switch (this) {
                case Psequel.Index.IndexType.BTREE:
                    return "BTREE";
                case Psequel.Index.IndexType.HASH:
                    return "HASH";
                case Psequel.Index.IndexType.GIST:
                    return "GIST";
                case Psequel.Index.IndexType.SPGIST:
                    return "SPGIST";
                case Psequel.Index.IndexType.GIN:
                    return "GIN";
                case Psequel.Index.IndexType.BRIN:
                    return "BRIN";
                case Psequel.Index.IndexType.USER_DEFINED:
                    return "USER_DEFINED";
                }

                return "";
            }

            public static IndexType[] all () {
                return {
                    BTREE,
                    HASH,
                    GIST,
                    SPGIST,
                    GIN,
                    BRIN,
                    USER_DEFINED
                };
            }

            public static IndexType from_string (string str) {
                var vals = IndexType.all ();
                for (int i = 0; i < vals.length; i++) {
                    if (str.ascii_up () == vals[i].to_string ()) {
                        return vals[i];
                    }
                }

                return USER_DEFINED;
            }
        }
    }

    public class Column : BaseType {

        public string column_type { get; set; default = ""; }
        public bool nullable { get; set; default = false; }
        public string default_val { get; set; default = ""; }

        public Column () {

        }
    }


    public class ForeignKey : BaseType {
        public string columns { get; set; default = ""; }
        public string fk_table { get; set; default = ""; }
        public string fk_columns { get; set; default = ""; }
        public FKType on_update { get; set; default = NO_ACTION; }
        public FKType on_delete { get; set; default = NO_ACTION; }

        private string _fk_def;
        public string fk_def {
            get {
                return _fk_def;
            }
            set {
                _fk_def = value;
                extract_info ();
            }
        }

        private void extract_info () {

            //  Match the index type and column from fk_def
            var regex = /FOREIGN KEY \(([$a-zA-Z_, ]+)\) REFERENCES ([a-zA-Z_, ]+)\(([a-zA-Z_, ]+)\)( ON UPDATE (CASCADE))?( ON DELETE (RESTRICT))?/;
            MatchInfo match_info;
            if (regex.match (fk_def, 0, out match_info)) {

                columns = match_info.fetch (1);
                fk_table = match_info.fetch (2);
                fk_columns = match_info.fetch (3);
                
                on_update = FKType.from_string (match_info.fetch (5));
                on_delete = FKType.from_string (match_info.fetch (7));

            } else {
                warning ("Regex not match: %s", fk_def);
            }
        }

        public enum FKType {
            NO_ACTION,
            RESTRICT,
            CASCADE;

            public string to_string () {
                switch (this) {
                case Psequel.ForeignKey.FKType.NO_ACTION:
                    return "NO_ACTION";
                case Psequel.ForeignKey.FKType.RESTRICT:
                    return "RESTRICT";
                case Psequel.ForeignKey.FKType.CASCADE:
                    return "CASCADE";

                }

                return "";
            }

            public static ForeignKey.FKType[] all () {
                return {
                    NO_ACTION,
                    RESTRICT,
                    CASCADE
                };
            }

            public static ForeignKey.FKType from_string (string str) {
                var vals = ForeignKey.FKType.all ();

                for (int i = 0; i < vals.length; i++) {
                    if (vals[i].to_string () == str.ascii_up ()) {
                        return vals[i];
                    }
                }

                return NO_ACTION;
            }
        }
    }
}