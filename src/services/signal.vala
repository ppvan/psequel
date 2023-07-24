namespace Psequel {

    /**
     * Application signals to comnicate between components.
     */
    public class AppSignals {

        /**
         * Emit when the table list changed.
         */
        public signal void table_list_changed ();
        public signal void views_list_changed ();

        public signal void schema_changed (Schema schema);

        public signal void table_selected_changed (string table);

        public signal void table_activated (Schema schema, string table);
        public signal void view_activated (Schema schema, string view);

        public signal void database_connected ();
        /**
         * Should only init onces by the resource manager. Should be single on but i'm lazy
         */
        public AppSignals () {
        }
    }
}