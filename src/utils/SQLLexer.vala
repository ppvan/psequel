namespace Psequel {

    /** Simple Lexer to separate SQL commands by ; */
    public class SQLLexer {


        public static List<Token> parse(string sql) {

            int lastToken = 0;
            List<Token> tokens = new List<Token> ();

            for (int i = 0; i < sql.length; i++) {
                if (sql[i] == ';') {
                    tokens.append(new Token() {
                        value = sql.substring(lastToken, i - lastToken),
                        start = lastToken,
                        end = i + 1
                    });

                    lastToken = i + 1;
                    while (sql[lastToken] == ' ' || sql[lastToken] == '\t' || sql[lastToken] == '\n' || sql[lastToken] == '\r') {
                        lastToken++;
                        i++;
                    }
                }
            }


            return tokens;
        }

        public class Token : Object {
            public string value { get; set; }
            public int start { get; set; }
            public int end { get; set; }

            public string to_string () {
                return value;
            }
        }
    }
}