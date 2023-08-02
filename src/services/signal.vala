namespace Psequel {

    /**
     * Window signals to comnicate between components.
     */
    public class WindowSignals : Object {

        /* Target connection in connection list changed */
        public signal void selection_changed (Connection conn);

        /* Request a db connection by click connect context menu */
        public signal void request_database_conn (Connection conn);
        /**
         * Emit when the table list changed.
         */
        public signal void table_list_changed ();
        public signal void views_list_changed ();

        public signal void schema_changed (Schema schema);

        public signal void table_selected_changed (string table);
        public signal void view_selected_changed (string vname);

        public signal void table_activated (Schema schema, string table);
        public signal void view_activated (Schema schema, string view);

        public signal void request_database (Connection conn);
        public signal void database_connected ();
        /**
         * Tied to one window and created by window.
         */
        public WindowSignals () {
            Object ();
        }

        public int number {get; set;}
    }

    /**
     * Application signals.
     */
    public class AppSignals : Object {

        public signal void window_ready ();

        public AppSignals () {
            Object ();
        }
    }
}