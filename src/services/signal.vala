namespace Psequel {

    /**
     * Application signals to comnicate between components.
     */
    public class AppSignals {

        /**
         * Emit when the table list changed.
         */
        public signal void table_list_changed ();

        /**
         * Should only init onces by the resource manager. Should be single on but i'm lazy
         */
        public AppSignals () {
        }
    }
}