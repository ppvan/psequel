namespace Psequel {
    public class CompleterService : Object, Observer {
        public SQLService sql_service { get; construct; }

        public List<string> schemas {get; owned set;}
        public List<string> tables {get; owned set;}
        public List<string> columns {get; owned set;}

        //  public List<Candidate> keywords { get; owned set; }

        public CompleterService (SQLService sql_service) {
            Object (sql_service: sql_service);
        }

        public List<Candidate> get_suggestions (SchemaContext context, string last_word) {
            // context maybe use in the future for smart completion or something.
            debug ("Lastword: %s", last_word);

            var keywords = suggest_keywords (last_word);
            var tables = suggest_tables (last_word);
            var columns = suggest_columns (last_word);
            var schemas = suggest_schemas (last_word);

            tables.concat ((owned)columns);
            schemas.concat ((owned)tables);
            keywords.concat ((owned)schemas);

            return keywords;
        }

        public void update (Event event) {
            if (event.type == Event.SCHEMA_CHANGED) {
                var schema = (Schema) event.data;
                refresh_data (schema);
            }
        }

        private List<Candidate> suggest_keywords (string prefix = "") {
            var candidates = new List<Candidate> ();

            for (int i = 0; i < PGListerals.KEYWORDS.length; i++) {
                var keyword = PGListerals.KEYWORDS[i];
                if (match (keyword, prefix)) {
                    candidates.append (new Candidate (PGListerals.KEYWORDS[i], "keyword"));
                }
            }

            return candidates;
        }

        private List<Candidate> suggest_columns (string prefix = "") {

            var candidates = new List<Candidate> ();
            columns.foreach ((item) => {
                if (match (item, prefix)) {
                    var cand = new Candidate (item, "column");
                    candidates.append (cand);
                }
            });

            return (owned)candidates;
        }

        private List<Candidate> suggest_schemas (string prefix = "") {

            var candidates = new List<Candidate> ();
            schemas.foreach ((item) => {
                if (match (item, prefix)) {
                    var cand = new Candidate (item, "schema");
                    candidates.append (cand);
                }
            });

            return (owned)candidates;
        }

        private List<Candidate> suggest_tables (string prefix = "") {

            var candidates = new List<Candidate> ();
            tables.foreach ((item) => {
                if (match (item, prefix)) {
                    var cand = new Candidate (item, "table");
                    candidates.append (cand);
                }
            });

            return (owned)candidates;
        }

        private bool match (string text, string needle) {
            return text.up ().has_prefix (needle.up ());
        }

        private void refresh_data (Schema schema) {
            refresh_columns ();
        }

        private void refresh_columns () {
            var query = new Query (COLUMN_LIST);
            sql_service.exec_query.begin (query, (obj, res) => {
                try {
                    var relation = sql_service.exec_query_params.end (res);
                    // avoid dupplicates
                    var tmp_schemas = new Tree<string, string> ((a, b) => { return strcmp (a, b); });
                    var tmp_tables = new Tree<string, string> ((a, b) => { return strcmp (a, b); });
                    var tmp_columns = new Tree<string, string> ((a, b) => { return strcmp (a, b); });

                    foreach (var row in relation) {
                        tmp_schemas.insert (row[0], row[0]);
                        tmp_tables.insert (row[1], row[1]);
                        tmp_columns.insert (row[2], row[2]);
                    }
                    schemas = new List<string> ();
                    tmp_schemas.foreach ((key, val) => {
                        schemas.append (val.dup ());
                        return false;
                    });

                    tables = new List<string> ();
                    tmp_tables.foreach ((key, val) => {
                        tables.append (val.dup ());
                        return false;
                    });

                    columns = new List<string> ();
                    tmp_columns.foreach ((key, val) => {
                        columns.append (val.dup ());

                        return false;
                    });

                } catch (PsequelError err) {
                    debug (err.message);
                }
            });
        }

        const string COLUMN_LIST = """SELECT table_schema, table_name, column_name
        FROM information_schema.columns""";
    }


    public class Candidate : Object, GtkSource.CompletionProposal {
        public string value { get; set; }
        public string group { get; set; }

        public Candidate (string value, string group) {
            this.value = value;
            this.group = group;
        }
    }

    public class  SchemaContext : Object {

    }

    public class PGListerals {
        public const string[] KEYWORDS = { "ADD", "ADD CONSTRAINT", "ALL", "ALTER", "ALTER COLUMN", "ALTER TABLE", "AND", "ANY", "AS", "ASC", "BACKUP DATABASE", "BETWEEN", "CASE", "CHECK", "COLUMN", "CONSTRAINT", "CREATE", "CREATE DATABASE", "CREATE INDEX", "CREATE OR REPLACE VIEW", "CREATE TABLE", "CREATE PROCEDURE", "CREATE UNIQUE INDEX", "CREATE VIEW", "DATABASE", "DEFAULT", "DELETE", "DESC", "DISTINCT", "DROP", "DROP COLUMN", "DROP CONSTRAINT", "DROP DATABASE", "DROP DEFAULT", "DROP INDEX", "DROP TABLE", "DROP VIEW", "EXEC", "EXISTS", "FOREIGN KEY", "FROM", "FULL OUTER JOIN", "GROUP BY", "HAVING", "IN", "INDEX", "INNER JOIN", "INSERT INTO", "IS NULL", "IS NOT NULL", "JOIN", "LEFT JOIN", "LIKE", "LIMIT", "NOT", "NOT NULL", "OR", "ORDER BY", "OUTER JOIN", "PRIMARY KEY", "PROCEDURE", "RIGHT JOIN", "ROWNUM", "SELECT", "SELECT DISTINCT", "SELECT INTO", "SELECT TOP", "SET", "TABLE", "TOP", "TRUNCATE TABLE", "UNION", "UNION ALL", "UNIQUE", "UPDATE", "VALUES", "VIEW", "WHERE"};
        public const string[] FUNCTIONS = { "ABBREV", "ABS", "AGE", "AREA", "ARRAY_AGG", "ARRAY_APPEND", "ARRAY_CAT", "ARRAY_DIMS", "ARRAY_FILL", "ARRAY_LENGTH", "ARRAY_LOWER", "ARRAY_NDIMS", "ARRAY_POSITION", "ARRAY_POSITIONS", "ARRAY_PREPEND", "ARRAY_REMOVE", "ARRAY_REPLACE", "ARRAY_TO_STRING", "ARRAY_UPPER", "ASCII", "AVG", "BIT_AND", "BIT_LENGTH", "BIT_OR", "BOOL_AND", "BOOL_OR", "BOUND_BOX", "BOX", "BROADCAST", "BTRIM", "CARDINALITY", "CBRT", "CEIL", "CEILING", "CENTER", "CHAR_LENGTH", "CHR", "CIRCLE", "CLOCK_TIMESTAMP", "CONCAT", "CONCAT_WS", "CONVERT", "CONVERT_FROM", "CONVERT_TO", "COUNT", "CUME_DIST", "CURRENT_DATE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "DATE_PART", "DATE_TRUNC", "DECODE", "DEGREES", "DENSE_RANK", "DIAMETER", "DIV", "ENCODE", "ENUM_FIRST", "ENUM_LAST", "ENUM_RANGE", "EVERY", "EXP", "EXTRACT", "FAMILY", "FIRST_VALUE", "FLOOR", "FORMAT", "GET_BIT", "GET_BYTE", "HEIGHT", "HOST", "HOSTMASK", "INET_MERGE", "INET_SAME_FAMILY", "INITCAP", "ISCLOSED", "ISFINITE", "ISOPEN", "JUSTIFY_DAYS", "JUSTIFY_HOURS", "JUSTIFY_INTERVAL", "LAG", "LAST_VALUE", "LEAD", "LEFT", "LENGTH", "LINE", "LN", "LOCALTIME", "LOCALTIMESTAMP", "LOG", "LOG10", "LOWER", "LPAD", "LSEG", "LTRIM", "MAKE_DATE", "MAKE_INTERVAL", "MAKE_TIME", "MAKE_TIMESTAMP", "MAKE_TIMESTAMPTZ", "MASKLEN", "MAX", "MD5", "MIN", "MOD", "NETMASK", "NETWORK", "NOW", "NPOINTS", "NTH_VALUE", "NTILE", "NUM_NONNULLS", "NUM_NULLS", "OCTET_LENGTH", "OVERLAY", "PARSE_IDENT", "PATH", "PCLOSE", "PERCENT_RANK", "PG_CLIENT_ENCODING", "PI", "POINT", "POLYGON", "POPEN", "POSITION", "POWER", "QUOTE_IDENT", "QUOTE_LITERAL", "QUOTE_NULLABLE", "RADIANS", "RADIUS", "RANDOM", "RANK", "REGEXP_MATCH", "REGEXP_MATCHES", "REGEXP_REPLACE", "REGEXP_SPLIT_TO_ARRAY", "REGEXP_SPLIT_TO_TABLE", "REPEAT", "REPLACE", "REVERSE", "RIGHT", "ROUND", "ROW_NUMBER", "RPAD", "RTRIM", "SCALE", "SET_BIT", "SET_BYTE", "SET_MASKLEN", "SHA224", "SHA256", "SHA384", "SHA512", "SIGN", "SPLIT_PART", "SQRT", "STARTS_WITH", "STATEMENT_TIMESTAMP", "STRING_TO_ARRAY", "STRPOS", "SUBSTR", "SUBSTRING", "SUM", "TEXT", "TIMEOFDAY", "TO_ASCII", "TO_CHAR", "TO_DATE", "TO_HEX", "TO_NUMBER", "TO_TIMESTAMP", "TRANSACTION_TIMESTAMP", "TRANSLATE", "TRIM", "TRUNC", "UNNEST", "UPPER", "WIDTH", "WIDTH_BUCKET", "XMLAGG" };
        public const string[] DATATYPES = { "ANY", "ANYARRAY", "ANYELEMENT", "ANYENUM", "ANYNONARRAY", "ANYRANGE", "BIGINT", "BIGSERIAL", "BIT", "BIT VARYING", "BOOL", "BOOLEAN", "BOX", "BYTEA", "CHAR", "CHARACTER", "CHARACTER VARYING", "CIDR", "CIRCLE", "CSTRING", "DATE", "DECIMAL", "DOUBLE PRECISION", "EVENT_TRIGGER", "FDW_HANDLER", "FLOAT4", "FLOAT8", "INET", "INT", "INT2", "INT4", "INT8", "INTEGER", "INTERNAL", "INTERVAL", "JSON", "JSONB", "LANGUAGE_HANDLER", "LINE", "LSEG", "MACADDR", "MACADDR8", "MONEY", "NUMERIC", "OID", "OPAQUE", "PATH", "PG_LSN", "POINT", "POLYGON", "REAL", "RECORD", "REGCLASS", "REGCONFIG", "REGDICTIONARY", "REGNAMESPACE", "REGOPER", "REGOPERATOR", "REGPROC", "REGPROCEDURE", "REGROLE", "REGTYPE", "SERIAL", "SERIAL2", "SERIAL4", "SERIAL8", "SMALLINT", "SMALLSERIAL", "TEXT", "TIME", "TIMESTAMP", "TRIGGER", "TSQUERY", "TSVECTOR", "TXID_SNAPSHOT", "UUID", "VARBIT", "VARCHAR", "VOID", "XML" };
        public const string[] RESERVED = { "ALL", "ANALYSE", "ANALYZE", "AND", "ANY", "ARRAY", "AS", "ASC", "ASYMMETRIC", "BOTH", "CASE", "CAST", "CHECK", "COLLATE", "COLUMN", "CONSTRAINT", "CREATE", "CURRENT_CATALOG", "CURRENT_DATE", "CURRENT_ROLE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "CURRENT_USER", "DEFAULT", "DEFERRABLE", "DESC", "DISTINCT", "DO", "ELSE", "END", "EXCEPT", "FALSE", "FETCH", "FOR", "FOREIGN", "FROM", "GRANT", "GROUP", "HAVING", "IN", "INITIALLY", "INTERSECT", "INTO", "LATERAL", "LEADING", "LIMIT", "LOCALTIME", "LOCALTIMESTAMP", "NOT", "NULL", "OFFSET", "ON", "ONLY", "OR", "ORDER", "PLACING", "PRIMARY", "REFERENCES", "RETURNING", "SELECT", "SESSION_USER", "SOME", "SYMMETRIC", "TABLE", "THEN", "TO", "TRAILING", "TRUE", "UNION", "UNIQUE", "USER", "USING", "VARIADIC", "WHEN", "WHERE", "WINDOW", "WITH", "AUTHORIZATION", "BINARY", "COLLATION", "CONCURRENTLY", "CROSS", "CURRENT_SCHEMA", "FREEZE", "FULL", "ILIKE", "INNER", "IS", "ISNULL", "JOIN", "LEFT", "LIKE", "NATURAL", "NOTNULL", "OUTER", "OVERLAPS", "RIGHT", "SIMILAR", "TABLESAMPLE", "VERBOSE" };
    }
}