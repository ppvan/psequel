
namespace Psequel {


    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-sidebar.ui")]
    public class ConnectionSidebar : Gtk.Box {


        const ActionEntry[] ACTION_ENTRIES = {
            { "connect", on_connect_connection },
            { "dupplicate", on_dupplicate_connection },
            { "delete", on_remove_connection },
        };

        public ObservableList<Connection> connections { get; set; }
        public Connection? selected_connection { get; set; }

        public signal void request_new_connection ();
        public signal void request_dup_connection (Connection conn);
        public signal void request_remove_connection (Connection conn);

        public ConnectionSidebar () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (ACTION_ENTRIES, this);
            this.insert_action_group ("conn", action_group);

            selection_model.bind_property ("selected", this, "selected-connection", DEFAULT | BIDIRECTIONAL, from_selected, to_selected);
        }

        // On add, create new connection and select it.
        [GtkCallback]
        public void on_add_connection (Gtk.Button btn) {
            request_new_connection ();
        }

        // [GtkAction]
        private void on_dupplicate_connection () {
            request_dup_connection (selected_connection);
        }

        // [GtkAction]
        private void on_connect_connection () {
            // viewmodel
            debug ("DEBUG");
        }

        // [GtkAction]
        private void on_remove_connection () {
            request_remove_connection (selected_connection);
        }

        private bool from_selected (Binding binding, Value from, ref Value to) {
            uint pos = from.get_uint ();

            if (pos != Gtk.INVALID_LIST_POSITION) {
                to.set_object (selection_model.get_item (pos));
            }

            return true;
        }

        private bool to_selected (Binding binding, Value from, ref Value to) {

            Connection conn = (Connection) from.get_object ();
            for (uint i = 0; i < selection_model.get_n_items (); i++) {
                if (selection_model.get_item (i) == conn) {
                    to.set_uint (i);
                    return true;
                }
            }

            to.set_uint (Gtk.INVALID_LIST_POSITION);

            return true;
        }

        [GtkChild]
        private unowned Gtk.SingleSelection selection_model;
    }

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-row.ui")]
    public class ConnectionRow : Gtk.Box {
        public Connection item { get; set; }
        public uint pos { get; set; }


        [GtkCallback]
        public void on_right_clicked () {
            var list_view = this.parent.parent as Gtk.ListView;
            list_view.model.select_item (pos, true);

            popover.popup ();
        }

        [GtkChild]
        private unowned Gtk.PopoverMenu popover;
    }
}