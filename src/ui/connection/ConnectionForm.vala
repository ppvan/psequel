namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-form.ui")]
    public class ConnectionForm : Adw.Bin {


        public MenuModel menu_model { get; set; }
        BindingGroup binddings;


        public Connection? selected_connection { get; set; }
        public bool is_connectting { get; set; }
        public string connection_url { get; set; default = ""; }

        public signal void request_database (Connection conn);
        public signal void connections_changed ();

        public ConnectionForm () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            // Create group to maped the entry widget to connection data.
            this.binddings = create_form_bind_group ();
            set_up_bindings ();
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

        private void set_up_bindings () {

            this.bind_property ("selected-connection", binddings, "source", BindingFlags.SYNC_CREATE);
            this.bind_property ("is-connectting", connect_btn, "sensitive", INVERT_BOOLEAN | SYNC_CREATE);
            connect_btn.bind_property ("sensitive", spinner, "spinning", BindingFlags.INVERT_BOOLEAN);
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

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            request_database (selected_connection);
        }

        [GtkCallback]
        private void on_entry_activated (Gtk.Entry entry) {
            connect_btn.clicked ();
        }

        [GtkCallback]
        private void on_text_changed (Gtk.Editable editable) {
            connections_changed ();
        }

        [GtkCallback]
        private void on_switch_changed () {
            connections_changed ();
        }

        [GtkChild]
        unowned Gtk.Button connect_btn;

        [GtkChild]
        unowned Gtk.Spinner spinner;

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
}