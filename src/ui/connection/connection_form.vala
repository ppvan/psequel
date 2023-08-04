namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/connection-form.ui")]
    public class ConnectionForm : Adw.Bin {

        BindingGroup binddings;

        public Connection selected {get; set;}
        public signal void connection_changed (Connection conn);

        public ConnectionForm () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            // Create group to maped the entry widget to connection data.
            this.binddings = new BindingGroup ();
            set_up_bindings (binddings);
            this.bind_property ("selected", binddings, "source", BindingFlags.SYNC_CREATE);
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

        private async void connect_database (QueryService service, Connection conn) {

            //  try {
            //      yield service.connect_db (conn);

            //      debug ("Emit database_connected");
            //      //  signals.database_connected ();
            //  } catch (PsequelError err) {
            //      var dialog = create_dialog ("Connection error", err.message);
            //      dialog.present ();
            //  }
        }

        //  [GtkCallback]
        private void on_url_entry_changed (Gtk.Editable editable) {

            //  if (editable.text == "") {
            //      url_entry.remove_css_class ("error");
            //      return;
            //  }

            //  if (!editable.text.has_prefix ("postgres://")) {
            //      err_label.label = "Invalid url, should start with postgres://";
            //      url_entry.add_css_class ("error");
            //      return;
            //  }


            //  url_entry.remove_css_class ("error");
            //  err_label.label = " ";
            //  try {
            //      var conn = query_service.parse_conninfo (editable.text);
            //      host_entry.text = conn.host;
            //      user_entry.text = conn.user;
            //      database_entry.text = conn.database;
            //      port_entry.text = conn.port;
            //      password_entry.text = conn.password;
            //      ssl_switch.active = conn.use_ssl;
            //  } catch (PsequelError err) {
            //      url_entry.add_css_class ("error");
            //      err_label.label = err.message;
            //  }
        }

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            //  btn.sensitive = false;
            //  connect_database.begin (this.query_service, this.mapped_conn, (obj, res) => {
            //      btn.sensitive = true;
            //  });
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
        private unowned Gtk.Entry url_entry;

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

        [GtkChild]
        private unowned Gtk.Label err_label;
    }
}