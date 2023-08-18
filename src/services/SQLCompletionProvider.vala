namespace Psequel {
    public class SQLCompletionProvider : Object, GtkSource.CompletionProvider {

        const string[] KEYWORDS = { "A", "ABORT", "ABS", "ABSENT", "ABSOLUTE", "ACCESS", "ACCORDING", "ACOS", "ACTION", "ADA", "ADD", "ADMIN", "AFTER", "AGGREGATE", "ALL", "ALLOCATE", "ALSO", "ALTER", "ALWAYS", "ANALYSE", "ANALYZE", "AND", "ANY", "ARE", "ARRAY", "ARRAY_AGG", "ARRAY_MAX_CARDINALITY", "AS", "ASC", "ASENSITIVE", "ASIN", "ASSERTION", "ASSIGNMENT", "ASYMMETRIC", "AT", "ATAN", "ATOMIC", "ATTACH", "ATTRIBUTE", "ATTRIBUTES", "AUTHORIZATION", "AVG", "BACKWARD", "BASE64", "BEFORE", "BEGIN", "BEGIN_FRAME", "BEGIN_PARTITION", "BERNOULLI", "BETWEEN", "BIGINT", "BINARY", "BIT", "BIT_LENGTH", "BLOB", "BLOCKED", "BOM", "BOOLEAN", "BOTH", "BREADTH", "BY", "C", "CACHE", "CALL", "CALLED", "CARDINALITY", "CASCADE", "CASCADED", "CASE", "CAST", "CATALOG", "CATALOG_NAME", "CEIL", "CEILING", "CHAIN", "CHAINING", "CHAR", "CHARACTER", "CHARACTERISTICS", "CHARACTERS", "CHARACTER_LENGTH", "CHARACTER_SET_CATALOG", "CHARACTER_SET_NAME", "CHARACTER_SET_SCHEMA", "CHAR_LENGTH", "CHECK", "CHECKPOINT", "CLASS", "CLASSIFIER", "CLASS_ORIGIN", "CLOB", "CLOSE", "CLUSTER", "COALESCE", "COBOL", "COLLATE", "COLLATION", "COLLATION_CATALOG", "COLLATION_NAME", "COLLATION_SCHEMA", "COLLECT", "COLUMN", "COLUMNS", "COLUMN_NAME", "COMMAND_FUNCTION", "COMMAND_FUNCTION_CODE", "COMMENT", "COMMENTS", "COMMIT", "COMMITTED", "COMPRESSION", "CONCURRENTLY", "CONDITION", "CONDITIONAL", "CONDITION_NUMBER", "CONFIGURATION", "CONFLICT", "CONNECT", "CONNECTION", "CONNECTION_NAME", "CONSTRAINT", "CONSTRAINTS", "CONSTRAINT_CATALOG", "CONSTRAINT_NAME", "CONSTRAINT_SCHEMA", "CONSTRUCTOR", "CONTAINS", "CONTENT", "CONTINUE", "CONTROL", "CONVERSION", "CONVERT", "COPY", "CORR", "CORRESPONDING", "COS", "COSH", "COST", "COUNT", "COVAR_POP", "COVAR_SAMP", "CREATE", "CROSS", "CSV", "CUBE", "CUME_DIST", "CURRENT", "CURRENT_CATALOG", "CURRENT_DATE", "CURRENT_DEFAULT_TRANSFORM_GROUP", "CURRENT_PATH", "CURRENT_ROLE", "CURRENT_ROW", "CURRENT_SCHEMA", "CURRENT_TIME", "CURRENT_TIMESTAMP", "CURRENT_TRANSFORM_GROUP_FOR_TYPE", "CURRENT_USER", "CURSOR", "CURSOR_NAME", "CYCLE", "DATA", "DATABASE", "DATALINK", "DATE", "DATETIME_INTERVAL_CODE", "DATETIME_INTERVAL_PRECISION", "DAY", "DB", "DEALLOCATE", "DEC", "DECFLOAT", "DECIMAL", "DECLARE", "DEFAULT", "DEFAULTS", "DEFERRABLE", "DEFERRED", "DEFINE", "DEFINED", "DEFINER", "DEGREE", "DELETE", "DELIMITER", "DELIMITERS", "DENSE_RANK", "DEPENDS", "DEPTH", "DEREF", "DERIVED", "DESC", "DESCRIBE", "DESCRIPTOR", "DETACH", "DETERMINISTIC", "DIAGNOSTICS", "DICTIONARY", "DISABLE", "DISCARD", "DISCONNECT", "DISPATCH", "DISTINCT", "DLNEWCOPY", "DLPREVIOUSCOPY", "DLURLCOMPLETE", "DLURLCOMPLETEONLY", "DLURLCOMPLETEWRITE", "DLURLPATH", "DLURLPATHONLY", "DLURLPATHWRITE", "DLURLSCHEME", "DLURLSERVER", "DLVALUE", "DO", "DOCUMENT", "DOMAIN", "DOUBLE", "DROP", "DYNAMIC", "DYNAMIC_FUNCTION", "DYNAMIC_FUNCTION_CODE", "EACH", "ELEMENT", "ELSE", "EMPTY", "ENABLE", "ENCODING", "ENCRYPTED", "END", "END-EXEC", "END_FRAME", "END_PARTITION", "ENFORCED", "ENUM", "EQUALS", "ERROR", "ESCAPE", "EVENT", "EVERY", "EXCEPT", "EXCEPTION", "EXCLUDE", "EXCLUDING", "EXCLUSIVE", "EXEC", "EXECUTE", "EXISTS", "EXP", "EXPLAIN", "EXPRESSION", "EXTENSION", "EXTERNAL", "EXTRACT", "FALSE", "FAMILY", "FETCH", "FILE", "FILTER", "FINAL", "FINALIZE", "FINISH", "FIRST", "FIRST_VALUE", "FLAG", "FLOAT", "FLOOR", "FOLLOWING", "FOR", "FORCE", "FOREIGN", "FORMAT", "FORTRAN", "FORWARD", "FOUND", "FRAME_ROW", "FREE", "FREEZE", "FROM", "FS", "FULFILL", "FULL", "FUNCTION", "FUNCTIONS", "FUSION", "G", "GENERAL", "GENERATED", "GET", "GLOBAL", "GO", "GOTO", "GRANT", "GRANTED", "GREATEST", "GROUP", "GROUPING", "GROUPS", "HANDLER", "HAVING", "HEADER", "HEX", "HIERARCHY", "HOLD", "HOUR", "ID", "IDENTITY", "IF", "IGNORE", "ILIKE", "IMMEDIATE", "IMMEDIATELY", "IMMUTABLE", "IMPLEMENTATION", "IMPLICIT", "IMPORT", "IN", "INCLUDE", "INCLUDING", "INCREMENT", "INDENT", "INDEX", "INDEXES", "INDICATOR", "INHERIT", "INHERITS", "INITIAL", "INITIALLY", "INLINE", "INNER", "INOUT", "INPUT", "INSENSITIVE", "INSERT", "INSTANCE", "INSTANTIABLE", "INSTEAD", "INT", "INTEGER", "INTEGRITY", "INTERSECT", "INTERSECTION", "INTERVAL", "INTO", "INVOKER", "IS", "ISNULL", "ISOLATION", "JOIN", "JSON_ARRAY", "JSON_ARRAYAGG", "JSON_EXISTS", "JSON_OBJECT", "JSON_OBJECTAGG", "JSON_QUERY", "JSON_TABLE", "JSON_TABLE_PRIMITIVE", "JSON_VALUE", "K", "KEEP", "KEY", "KEYS", "KEY_MEMBER", "KEY_TYPE", "LABEL", "LAG", "LANGUAGE", "LARGE", "LAST", "LAST_VALUE", "LATERAL", "LEAD", "LEADING", "LEAKPROOF", "LEAST", "LEFT", "LENGTH", "LEVEL", "LIBRARY", "LIKE", "LIKE_REGEX", "LIMIT", "LINK", "LISTAGG", "LISTEN", "LN", "LOAD", "LOCAL", "LOCALTIME", "LOCALTIMESTAMP", "LOCATION", "LOCATOR", "LOCK", "LOCKED", "LOG", "LOG10", "LOGGED", "LOWER", "M", "MAP", "MAPPING", "MATCH", "MATCHED", "MATCHES", "MATCH_NUMBER", "MATCH_RECOGNIZE", "MATERIALIZED", "MAX", "MAXVALUE", "MEASURES", "MEMBER", "MERGE", "MESSAGE_LENGTH", "MESSAGE_OCTET_LENGTH", "MESSAGE_TEXT", "METHOD", "MIN", "MINUTE", "MINVALUE", "MOD", "MODE", "MODIFIES", "MODULE", "MONTH", "MORE", "MOVE", "MULTISET", "MUMPS", "NAME", "NAMES", "NAMESPACE", "NATIONAL", "NATURAL", "NCHAR", "NCLOB", "NESTED", "NESTING", "NEW", "NEXT", "NFC", "NFD", "NFKC", "NFKD", "NIL", "NO", "NONE", "NORMALIZE", "NORMALIZED", "NOT", "NOTHING", "NOTIFY", "NOTNULL", "NOWAIT", "NTH_VALUE", "NTILE", "NULL", "NULLABLE", "NULLIF", "NULLS", "NULL_ORDERING", "NUMBER", "NUMERIC", "OBJECT", "OCCURRENCE", "OCCURRENCES_REGEX", "OCTETS", "OCTET_LENGTH", "OF", "OFF", "OFFSET", "OIDS", "OLD", "OMIT", "ON", "ONE", "ONLY", "OPEN", "OPERATOR", "OPTION", "OPTIONS", "OR", "ORDER", "ORDERING", "ORDINALITY", "OTHERS", "OUT", "OUTER", "OUTPUT", "OVER", "OVERFLOW", "OVERLAPS", "OVERLAY", "OVERRIDING", "OWNED", "OWNER", "P", "PAD", "PARALLEL", "PARAMETER", "PARAMETER_MODE", "PARAMETER_NAME", "PARAMETER_ORDINAL_POSITION", "PARAMETER_SPECIFIC_CATALOG", "PARAMETER_SPECIFIC_NAME", "PARAMETER_SPECIFIC_SCHEMA", "PARSER", "PARTIAL", "PARTITION", "PASCAL", "PASS", "PASSING", "PASSTHROUGH", "PASSWORD", "PAST", "PATH", "PATTERN", "PER", "PERCENT", "PERCENTILE_CONT", "PERCENTILE_DISC", "PERCENT_RANK", "PERIOD", "PERMISSION", "PERMUTE", "PIPE", "PLACING", "PLAN", "PLANS", "PLI", "POLICY", "PORTION", "POSITION", "POSITION_REGEX", "POWER", "PRECEDES", "PRECEDING", "PRECISION", "PREPARE", "PREPARED", "PRESERVE", "PREV", "PRIMARY", "PRIOR", "PRIVATE", "PRIVILEGES", "PROCEDURAL", "PROCEDURE", "PROCEDURES", "PROGRAM", "PRUNE", "PTF", "PUBLIC", "PUBLICATION", "QUOTE", "QUOTES", "RANGE", "RANK", "READ", "READS", "REAL", "REASSIGN", "RECHECK", "RECOVERY", "RECURSIVE", "REF", "REFERENCES", "REFERENCING", "REFRESH", "REGR_AVGX", "REGR_AVGY", "REGR_COUNT", "REGR_INTERCEPT", "REGR_R2", "REGR_SLOPE", "REGR_SXX", "REGR_SXY", "REGR_SYY", "REINDEX", "RELATIVE", "RELEASE", "RENAME", "REPEATABLE", "REPLACE", "REPLICA", "REQUIRING", "RESET", "RESPECT", "RESTART", "RESTORE", "RESTRICT", "RESULT", "RETURN", "RETURNED_CARDINALITY", "RETURNED_LENGTH", "RETURNED_OCTET_LENGTH", "RETURNED_SQLSTATE", "RETURNING", "RETURNS", "REVOKE", "RIGHT", "ROLE", "ROLLBACK", "ROLLUP", "ROUTINE", "ROUTINES", "ROUTINE_CATALOG", "ROUTINE_NAME", "ROUTINE_SCHEMA", "ROW", "ROWS", "ROW_COUNT", "ROW_NUMBER", "RULE", "RUNNING", "SAVEPOINT", "SCALAR", "SCALE", "SCHEMA", "SCHEMAS", "SCHEMA_NAME", "SCOPE", "SCOPE_CATALOG", "SCOPE_NAME", "SCOPE_SCHEMA", "SCROLL", "SEARCH", "SECOND", "SECTION", "SECURITY", "SEEK", "SELECT", "SELECTIVE", "SELF", "SEMANTICS", "SENSITIVE", "SEQUENCE", "SEQUENCES", "SERIALIZABLE", "SERVER", "SERVER_NAME", "SESSION", "SESSION_USER", "SET", "SETOF", "SETS", "SHARE", "SHOW", "SIMILAR", "SIMPLE", "SIN", "SINH", "SIZE", "SKIP", "SMALLINT", "SNAPSHOT", "SOME", "SORT_DIRECTION", "SOURCE", "SPACE", "SPECIFIC", "SPECIFICTYPE", "SPECIFIC_NAME", "SQL", "SQLCODE", "SQLERROR", "SQLEXCEPTION", "SQLSTATE", "SQLWARNING", "SQRT", "STABLE", "STANDALONE", "START", "STATE", "STATEMENT", "STATIC", "STATISTICS", "STDDEV_POP", "STDDEV_SAMP", "STDIN", "STDOUT", "STORAGE", "STORED", "STRICT", "STRING", "STRIP", "STRUCTURE", "STYLE", "SUBCLASS_ORIGIN", "SUBMULTISET", "SUBSCRIPTION", "SUBSET", "SUBSTRING", "SUBSTRING_REGEX", "SUCCEEDS", "SUM", "SUPPORT", "SYMMETRIC", "SYSID", "SYSTEM", "SYSTEM_TIME", "SYSTEM_USER", "T", "TABLE", "TABLES", "TABLESAMPLE", "TABLESPACE", "TABLE_NAME", "TAN", "TANH", "TEMP", "TEMPLATE", "TEMPORARY", "TEXT", "THEN", "THROUGH", "TIES", "TIME", "TIMESTAMP", "TIMEZONE_HOUR", "TIMEZONE_MINUTE", "TO", "TOKEN", "TOP_LEVEL_COUNT", "TRAILING", "TRANSACTION", "TRANSACTIONS_COMMITTED", "TRANSACTIONS_ROLLED_BACK", "TRANSACTION_ACTIVE", "TRANSFORM", "TRANSFORMS", "TRANSLATE", "TRANSLATE_REGEX", "TRANSLATION", "TREAT", "TRIGGER", "TRIGGER_CATALOG", "TRIGGER_NAME", "TRIGGER_SCHEMA", "TRIM", "TRIM_ARRAY", "TRUE", "TRUNCATE", "TRUSTED", "TYPE", "TYPES", "UESCAPE", "UNBOUNDED", "UNCOMMITTED", "UNCONDITIONAL", "UNDER", "UNENCRYPTED", "UNION", "UNIQUE", "UNKNOWN", "UNLINK", "UNLISTEN", "UNLOGGED", "UNMATCHED", "UNNAMED", "UNNEST", "UNTIL", "UNTYPED", "UPDATE", "UPPER", "URI", "USAGE", "USER", "USER_DEFINEDTYPE_CATALOG", "USER_DEFINED_TYPE_CODE", "USER_DEFINED_TYPE_NAME", "USER_DEFINED_TYPE_SCHEMA", "USING", "UTF16", "UTF32", "UTF8", "VACUUM", "VALID", "VALIDATE", "VALIDATOR", "VALUE", "VALUES", "VALUE_OF", "VARBINARY", "VARCHAR", "VARIADIC", "VARYING", "VAR_POP", "VAR_SAMP", "VERBOSE", "VERSION", "VERSIONING", "VIEW", "VIEWS", "VOLATILE", "WHEN", "WHENEVER", "WHERE", "WHITESPACE", "WIDTH_BUCKET", "WINDOW", "WITH", "WITHIN", "WITHOUT", "WORK", "WRAPPER", "WRITE", "XML", "XMLAGG", "XMLATTRIBUTES", "XMLBINARY", "XMLCAST", "XMLCOMMENT", "XMLCONCAT", "XMLDECLARATION", "XMLDOCUMENT", "XMLELEMENT", "XMLEXISTS", "XMLFOREST", "XMLITERATE", "XMLNAMESPACES", "XMLPARSE", "XMLPI", "XMLQUERY", "XMLROOT", "XMLSCHEMA", "XMLSERIALIZE", "XMLTABLE", "XMLTEXT", "XMLVALIDATE", "YEAR", "YES", "ZONE" };

        private List<Model> static_candidates;
        private List<Model> dynamic_candidates;
        private Gtk.FilterListModel model;
        private Gtk.StringFilter filter;

        public QueryViewModel query_viewmodel { get; set; }

        public SQLCompletionProvider () {
            base ();
            debug ("SQLCompletionProvider");

            static_candidates = new List<Model> ();
            for (int i = 0; i < PGListerals.KEYWORDS.length; i++) {
                static_candidates.append (new Model (PGListerals.KEYWORDS[i], "KEYWORD"));
            }

            for (int i = 0; i < PGListerals.FUNCTIONS.length; i++) {
                static_candidates.append (new Model (PGListerals.FUNCTIONS[i], "FUNCTION"));
            }

            for (int i = 0; i < PGListerals.DATATYPES.length; i++) {
                static_candidates.append (new Model (PGListerals.DATATYPES[i], "DATATYPE"));
            }

            for (int i = 0; i < PGListerals.RESERVED.length; i++) {
                static_candidates.append (new Model (PGListerals.RESERVED[i], "RESERVED"));
            }

            /*
                Query viewmodel is not set until the query view is created.
             */
            dynamic_candidates = new List<Model> ();
            this.notify["query-viewmodel"].connect (() => {

                dynamic_candidates = new List<Model> ();
                query_viewmodel.current_schema.tables.foreach ((table) => {
                    dynamic_candidates.append (new Model (table.name, "TABLE"));
                });

                query_viewmodel.current_schema.views.foreach ((view) => {
                    dynamic_candidates.append (new Model (view.name, "VIEW"));
                });
            });

            var expression = new Gtk.PropertyExpression (typeof (Model), null, "value");
            filter = new Gtk.StringFilter (expression);
            filter.match_mode = Gtk.StringFilterMatchMode.PREFIX;

            model = new Gtk.FilterListModel (null, filter);
        }

        public void activate (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal) {
            debug ("activate 1");

            var model = (Model) proposal;
            var buf = context.get_buffer ();
            Gtk.TextIter start, end;

            last_word (buf, out start, out end);

            buf.delete_range (start, end);
            buf.insert_at_cursor (model.value, model.value.length);
            // buf.insert (ref iter, model.value, model.value.length);
        }

        public void display (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal, GtkSource.CompletionCell cell) {

            var model = (Model) proposal;

            // cell.text = cell.column.to_string ();

            switch (cell.column) {
            // name
            case GtkSource.CompletionColumn.TYPED_TEXT:
                cell.text = model.value;
                break;

            // group
            case GtkSource.CompletionColumn.AFTER:
                cell.text = model.group;
                break;
            // case GtkSource.CompletionColumn.DETAILS:
            // cell.text = "DETAILS";
            // break;
            // case GtkSource.CompletionColumn.COMMENT:
            // cell.text = "COMMENT";
            // break;
            // case GtkSource.CompletionColumn.ICON:
            // cell.text = "ICON";
            // break;
            // case GtkSource.CompletionColumn.BEFORE:
            // cell.text = "BEFORE";
            // break;
            default: break;
            }
        }

        public async GLib.ListModel populate_async (GtkSource.CompletionContext context, GLib.Cancellable? cancellable) {

            var candidates = new ObservableList<Model> ();
            candidates.append_all (static_candidates);
            candidates.append_all (dynamic_candidates);
            model.model = candidates;


            var word = last_word (context.get_buffer ());
            filter.search = word;
            debug ("populate_async: %s", word);
            debug ("size: %u", model.get_n_items ());

            return model;
        }

        public void refilter (GtkSource.CompletionContext context, GLib.ListModel _model) {

            debug ("refilter");

            var word = last_word (context.get_buffer ());
            filter.search = word;
            filter.changed (Gtk.FilterChange.MORE_STRICT);
            debug ("populate_async: %s", word);
        }

        public class Model : Object, GtkSource.CompletionProposal {
            public string value { get; set; }
            public string group { get; set; }

            public Model (string value, string group) {
                this.value = value;
                this.group = group;
            }
        }

        private string last_word (GtkSource.Buffer buf, out Gtk.TextIter start = null, out Gtk.TextIter end = null) {
            Gtk.TextIter iter;
            buf.get_iter_at_offset (out iter, buf.cursor_position);

            start = iter;
            end = iter;

            start.backward_word_start ();
            end.forward_word_end ();

            return buf.get_text (start, end, false);
        }
    }


    public class PGListerals {
        public const string[] KEYWORDS = { "ADD", "ADD CONSTRAINT", "ALL", "ALTER", "ALTER COLUMN", "ALTER TABLE", "AND", "ANY", "AS", "ASC", "BACKUP DATABASE", "BETWEEN", "CASE", "CHECK", "COLUMN", "CONSTRAINT", "CREATE", "CREATE DATABASE", "CREATE INDEX", "CREATE OR REPLACE VIEW", "CREATE TABLE", "CREATE PROCEDURE", "CREATE UNIQUE INDEX", "CREATE VIEW", "DATABASE", "DEFAULT", "DELETE", "DESC", "DISTINCT", "DROP", "DROP COLUMN", "DROP CONSTRAINT", "DROP DATABASE", "DROP DEFAULT", "DROP INDEX", "DROP TABLE", "DROP VIEW", "EXEC", "EXISTS", "FOREIGN KEY", "FROM", "FULL OUTER JOIN", "GROUP BY", "HAVING", "IN", "INDEX", "INNER JOIN", "INSERT INTO", "INSERT INTO SELECT", "IS NULL", "IS NOT NULL", "JOIN", "LEFT JOIN", "LIKE", "LIMIT", "NOT", "NOT NULL", "OR", "ORDER BY", "OUTER JOIN", "PRIMARY KEY", "PROCEDURE", "RIGHT JOIN", "ROWNUM", "SELECT", "SELECT DISTINCT", "SELECT INTO", "SELECT TOP", "SET", "TABLE", "TOP", "TRUNCATE TABLE", "UNION", "UNION ALL", "UNIQUE", "UPDATE", "VALUES", "VIEW", "WHERE" };
        public const string[] FUNCTIONS = { "ABBREV", "ABS", "AGE", "AREA", "ARRAY_AGG", "ARRAY_APPEND", "ARRAY_CAT", "ARRAY_DIMS", "ARRAY_FILL", "ARRAY_LENGTH", "ARRAY_LOWER", "ARRAY_NDIMS", "ARRAY_POSITION", "ARRAY_POSITIONS", "ARRAY_PREPEND", "ARRAY_REMOVE", "ARRAY_REPLACE", "ARRAY_TO_STRING", "ARRAY_UPPER", "ASCII", "AVG", "BIT_AND", "BIT_LENGTH", "BIT_OR", "BOOL_AND", "BOOL_OR", "BOUND_BOX", "BOX", "BROADCAST", "BTRIM", "CARDINALITY", "CBRT", "CEIL", "CEILING", "CENTER", "CHAR_LENGTH", "CHR", "CIRCLE", "CLOCK_TIMESTAMP", "CONCAT", "CONCAT_WS", "CONVERT", "CONVERT_FROM", "CONVERT_TO", "COUNT", "CUME_DIST", "CURRENT_DATE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "DATE_PART", "DATE_TRUNC", "DECODE", "DEGREES", "DENSE_RANK", "DIAMETER", "DIV", "ENCODE", "ENUM_FIRST", "ENUM_LAST", "ENUM_RANGE", "EVERY", "EXP", "EXTRACT", "FAMILY", "FIRST_VALUE", "FLOOR", "FORMAT", "GET_BIT", "GET_BYTE", "HEIGHT", "HOST", "HOSTMASK", "INET_MERGE", "INET_SAME_FAMILY", "INITCAP", "ISCLOSED", "ISFINITE", "ISOPEN", "JUSTIFY_DAYS", "JUSTIFY_HOURS", "JUSTIFY_INTERVAL", "LAG", "LAST_VALUE", "LEAD", "LEFT", "LENGTH", "LINE", "LN", "LOCALTIME", "LOCALTIMESTAMP", "LOG", "LOG10", "LOWER", "LPAD", "LSEG", "LTRIM", "MAKE_DATE", "MAKE_INTERVAL", "MAKE_TIME", "MAKE_TIMESTAMP", "MAKE_TIMESTAMPTZ", "MASKLEN", "MAX", "MD5", "MIN", "MOD", "NETMASK", "NETWORK", "NOW", "NPOINTS", "NTH_VALUE", "NTILE", "NUM_NONNULLS", "NUM_NULLS", "OCTET_LENGTH", "OVERLAY", "PARSE_IDENT", "PATH", "PCLOSE", "PERCENT_RANK", "PG_CLIENT_ENCODING", "PI", "POINT", "POLYGON", "POPEN", "POSITION", "POWER", "QUOTE_IDENT", "QUOTE_LITERAL", "QUOTE_NULLABLE", "RADIANS", "RADIUS", "RANDOM", "RANK", "REGEXP_MATCH", "REGEXP_MATCHES", "REGEXP_REPLACE", "REGEXP_SPLIT_TO_ARRAY", "REGEXP_SPLIT_TO_TABLE", "REPEAT", "REPLACE", "REVERSE", "RIGHT", "ROUND", "ROW_NUMBER", "RPAD", "RTRIM", "SCALE", "SET_BIT", "SET_BYTE", "SET_MASKLEN", "SHA224", "SHA256", "SHA384", "SHA512", "SIGN", "SPLIT_PART", "SQRT", "STARTS_WITH", "STATEMENT_TIMESTAMP", "STRING_TO_ARRAY", "STRPOS", "SUBSTR", "SUBSTRING", "SUM", "TEXT", "TIMEOFDAY", "TO_ASCII", "TO_CHAR", "TO_DATE", "TO_HEX", "TO_NUMBER", "TO_TIMESTAMP", "TRANSACTION_TIMESTAMP", "TRANSLATE", "TRIM", "TRUNC", "UNNEST", "UPPER", "WIDTH", "WIDTH_BUCKET", "XMLAGG" };
        public const string[] DATATYPES = { "ANY", "ANYARRAY", "ANYELEMENT", "ANYENUM", "ANYNONARRAY", "ANYRANGE", "BIGINT", "BIGSERIAL", "BIT", "BIT VARYING", "BOOL", "BOOLEAN", "BOX", "BYTEA", "CHAR", "CHARACTER", "CHARACTER VARYING", "CIDR", "CIRCLE", "CSTRING", "DATE", "DECIMAL", "DOUBLE PRECISION", "EVENT_TRIGGER", "FDW_HANDLER", "FLOAT4", "FLOAT8", "INET", "INT", "INT2", "INT4", "INT8", "INTEGER", "INTERNAL", "INTERVAL", "JSON", "JSONB", "LANGUAGE_HANDLER", "LINE", "LSEG", "MACADDR", "MACADDR8", "MONEY", "NUMERIC", "OID", "OPAQUE", "PATH", "PG_LSN", "POINT", "POLYGON", "REAL", "RECORD", "REGCLASS", "REGCONFIG", "REGDICTIONARY", "REGNAMESPACE", "REGOPER", "REGOPERATOR", "REGPROC", "REGPROCEDURE", "REGROLE", "REGTYPE", "SERIAL", "SERIAL2", "SERIAL4", "SERIAL8", "SMALLINT", "SMALLSERIAL", "TEXT", "TIME", "TIMESTAMP", "TRIGGER", "TSQUERY", "TSVECTOR", "TXID_SNAPSHOT", "UUID", "VARBIT", "VARCHAR", "VOID", "XML" };
        public const string[] RESERVED = { "ALL", "ANALYSE", "ANALYZE", "AND", "ANY", "ARRAY", "AS", "ASC", "ASYMMETRIC", "BOTH", "CASE", "CAST", "CHECK", "COLLATE", "COLUMN", "CONSTRAINT", "CREATE", "CURRENT_CATALOG", "CURRENT_DATE", "CURRENT_ROLE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "CURRENT_USER", "DEFAULT", "DEFERRABLE", "DESC", "DISTINCT", "DO", "ELSE", "END", "EXCEPT", "FALSE", "FETCH", "FOR", "FOREIGN", "FROM", "GRANT", "GROUP", "HAVING", "IN", "INITIALLY", "INTERSECT", "INTO", "LATERAL", "LEADING", "LIMIT", "LOCALTIME", "LOCALTIMESTAMP", "NOT", "NULL", "OFFSET", "ON", "ONLY", "OR", "ORDER", "PLACING", "PRIMARY", "REFERENCES", "RETURNING", "SELECT", "SESSION_USER", "SOME", "SYMMETRIC", "TABLE", "THEN", "TO", "TRAILING", "TRUE", "UNION", "UNIQUE", "USER", "USING", "VARIADIC", "WHEN", "WHERE", "WINDOW", "WITH", "AUTHORIZATION", "BINARY", "COLLATION", "CONCURRENTLY", "CROSS", "CURRENT_SCHEMA", "FREEZE", "FULL", "ILIKE", "INNER", "IS", "ISNULL", "JOIN", "LEFT", "LIKE", "NATURAL", "NOTNULL", "OUTER", "OVERLAPS", "RIGHT", "SIMILAR", "TABLESAMPLE", "VERBOSE" };
    }
}