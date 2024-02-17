
namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-view.ui")]
    public class ConnectionView : Adw.Bin {

        public ConnectionViewModel viewmodel { get; private set; }
        public ObservableList<Connection> connections { get; set; }
        public Connection? selected_connection { get; set; }

        BindingGroup bindings;

        const ActionEntry[] ACTION_ENTRIES = {
            { "connect", on_connect_connection },
            { "dupplicate", on_dupplicate_connection },
            { "delete", on_remove_connection },
        };

        public ConnectionView (Application app) {
            Object ();
        }

        // Connect event.
        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_paned (paned);
            viewmodel = autowire<ConnectionViewModel> ();

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (ACTION_ENTRIES, this);
            this.insert_action_group ("conn", action_group);

            set_up_bindings ();
        }

        //  [GtkCallback]
        //  public void save_connections () {
        //      viewmodel.save_connections ();
        //  }

        [GtkCallback]
        public void add_new_connection () {
            viewmodel.new_connection ();
        }

        [GtkCallback]
        public void active_connection (Gtk.ListView view, uint pos) {
            viewmodel.active_connection.begin (viewmodel.selected_connection);
        }

        [GtkCallback]
        public void on_connect_clicked (Gtk.Button btn) {
            viewmodel.active_connection.begin (viewmodel.selected_connection);
        }

        [GtkCallback]
        private void on_entry_activated (Gtk.Entry entry) {
            on_connect_connection();
        }

        [GtkCallback]
        private void on_text_changed (Gtk.Editable editable) {
            viewmodel.save_connections ();
        }

        [GtkCallback]
        private void on_switch_changed () {
            viewmodel.save_connections ();
        }

        // [GtkAction]
        private void on_dupplicate_connection () {
            viewmodel.dupplicate_connection (viewmodel.selected_connection);
        }

        // [GtkAction]
        private void on_connect_connection () {
            viewmodel.active_connection.begin (viewmodel.selected_connection);
        }

        // [GtkAction]
        private void on_remove_connection () {
            viewmodel.remove_connection (viewmodel.selected_connection);
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

        private void set_up_bindings () {
            
            //  Save ref so it does not be cleaned
            this.bindings = create_form_bind_group ();

            viewmodel.bind_property ("selected-connection", this.bindings, "source", BindingFlags.SYNC_CREATE);
            viewmodel.bind_property ("is-connectting", connect_btn, "sensitive", INVERT_BOOLEAN | SYNC_CREATE);
            selection_model.bind_property ("selected", viewmodel, "selected-connection",
                                           DEFAULT | BIDIRECTIONAL, from_selected, to_selected);
            password_entry.bind_property ("text",
                                          password_entry,
                                          "show-peek-icon",
                                          BindingFlags.SYNC_CREATE,
                                          (binding, from_value, ref to_value) => {

                string text = from_value.get_string ();
                to_value.set_boolean (text.length > 0);

                return true;
            });


        }

        private BindingGroup create_form_bind_group () {

            var binddings = new BindingGroup ();
            debug ("set_up connection form bindings group");
            binddings.bind ("name", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("host", host_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("port", port_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("user", user_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("password", password_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("database", database_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            binddings.bind ("use_ssl", ssl_switch, "active", SYNC_CREATE | BIDIRECTIONAL);
            debug ("set_up binddings done");


            return binddings;
        }

        [GtkChild]
        private unowned Gtk.SingleSelection selection_model;
        [GtkChild]
        private unowned Gtk.Paned paned;


        [GtkChild]
        private unowned Gtk.Button connect_btn;

        [GtkChild]
        private unowned Gtk.Entry name_entry;

        [GtkChild]
        private unowned Gtk.Entry host_entry;
        [GtkChild]
        private unowned Gtk.Entry port_entry;
        [GtkChild]
        private unowned Gtk.Entry user_entry;
        [GtkChild]
        private unowned Gtk.PasswordEntry password_entry;

        [GtkChild]
        private unowned Gtk.Entry database_entry;

        [GtkChild]
        private unowned Gtk.Switch ssl_switch;
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