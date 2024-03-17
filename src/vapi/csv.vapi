/* libcsv.vapi
 */

[CCode(cprefix = "csv_", cheader_filename = "csv.h")]
namespace Csv {

    public const uchar STRICT;
    public const uchar REPALL_NL;
    public const uchar STRICT_FINI;
    public const uchar APPEND_NULL;
    public const uchar EMPTY_IS_NULL;

    public const int SUCCESS;
    public const int ENOMEN;
    public const int ETOOBIG;
    public const int EINVALID;

    public const uchar TAB;
    public const uchar SPACE;
    public const uchar CR;
    public const uchar COMMA;
    public const uchar QUOTE;




    [Compact]
    [CCode(cname = "struct csv_parser", free_function = "csv_free")]
    public struct Parser {

        [CCode(cname = "csv_init")]
        public Parser(uchar options);

        [CCode(cname = "csv_error")]
        public int error();

        [CCode(cname = "csv_strerror")]
        public string strerror();

        [CCode(cname = "csv_get_opts")]
        public int get_opts();

        [CCode(cname = "csv_set_opts")]
        public int set_opts();

        [CCode(cname = "csv_set_delim")]
        public void set_delim(uchar ch);

        [CCode(cname = "csv_set_quote")]
        public void set_quote(uchar ch);

        [CCode(cname = "csv_get_delim")]
        public uchar get_delim();

        [CCode(cname = "csv_get_quote")]
        public uchar get_quote();

        [CCode(cname = "csv_get_buffer_size")]
        public int get_buffer_size();

        [CCode(cname = "csv_write", simple_generics = true)]
        public static uint32 write_internal < T > (T[] dest, T[] src);
    }

    public static string quote(string src) {

        if (src.length >= int.MAX / 2) {
            return "<source input too large>";
        }

        int buf_size = src.length > 1024 ? src.length * 2 : 2048;

        uint8[] buf = new uint8[buf_size];
        Parser.write_internal < uint8 > (buf, src.data);

        return (string) buf;
    }
}