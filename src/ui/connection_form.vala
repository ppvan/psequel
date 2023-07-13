namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/conn-form.ui")]
    public class ConnectionForm : Gtk.Box {

        BindingGroup binddings;

        private unowned QueryService query_service;

        private Connection _conn;
        public Connection mapped_conn {
            get {
                return _conn;
            }
            set {
                _conn = value;
                binddings.source = _conn;
            }
        }

        public ConnectionSidebar sidebar { get; set; }

        public ConnectionForm () {
            Object ();
        }

        construct {
            // init service
            query_service = ResourceManager.instance ().query_service;

            // Create group to maped the entry widget to connection data.
            this.binddings = new BindingGroup ();
            set_up_bindings (binddings);
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

            debug ("set_up binddings done");
        }

        [GtkCallback]
        private void on_connect_clicked (Gtk.Button btn) {
            // name_entry.buffer.text = "Hello world";
            // i want to save it
            //  btn.set_sensitive (false);
            debug ("Connecting to %s", mapped_conn.url_form ());

            TimePerf.begin ();
            with (ResourceManager.instance ()) {
                query_service.connect_db_async.begin (mapped_conn, (obj, res) => {
                    btn.set_sensitive (true);
                    TimePerf.end ();
                    var tmp = obj as QueryService;
                    tmp.connect_db_async.end (res);

                    tmp.db_version.begin ((obj, res) => {

                        string version = tmp.db_version.end (res);
                        debug (version);
                    });
                });
            }
        }

        [GtkCallback]
        private void on_entry_activated (Gtk.Entry entry) {
            connect_btn.clicked ();
        }

        [GtkChild]
        unowned Gtk.Button connect_btn;

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
        private unowned Gtk.Label info;
    }
}