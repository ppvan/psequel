namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-form.ui")]
    public class ConnectionForm : Adw.Bin {


        public MenuModel menu_model { get; set; }
        public bool is_connectting {get; set;}

        BindingGroup binddings;

        public Connection selected { get; set; }
        public signal void connection_changed (Connection conn);
        public signal void request_database (Connection conn);

        public ConnectionForm () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            // Create group to maped the entry widget to connection data.
            this.binddings = new BindingGroup ();
            set_up_bindings (binddings);
            this.bind_property ("selected", binddings, "source", BindingFlags.SYNC_CREATE);
            this.bind_property ("is-connectting", connect_btn, "sensitive", INVERT_BOOLEAN | SYNC_CREATE);
        }


        private void set_up_bindings (BindingGroup group) {
            debug ("set_up connection form bindings group");

            group.bind ("name", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            group.bind ("host", host_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            group.bind ("port", port_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            group.bind ("user", user_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            group.bind ("password", password_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            group.bind ("database", database_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
            group.bind ("use_ssl", ssl_switch, "active", SYNC_CREATE | BIDIRECTIONAL);


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

            debug ("set_up binddings done");
        }

        [GtkCallback]
        private void text_changed_cb () {
            connection_changed (selected);
        }

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            request_database (selected);
        }

        [GtkCallback]
        private void on_entry_activated (Gtk.Entry entry) {
            connect_btn.clicked ();
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