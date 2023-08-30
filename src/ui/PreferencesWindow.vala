namespace Psequel {

    // valalint=skip-file
    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/preferences-window.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        //  const ActionEntry[] ACTION_ENTRIES = {
        //      { "editor-font", old_choser },
        //  };

        public PreferencesWindow () {
            Object ();
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);
            setup_binding ();
            defaults ();
        }


        private void defaults () {
            var desc = Pango.FontDescription.from_string (Application.settings.get_string ("editor-font"));

            font_label.get_pango_context ().set_font_description (desc);
            font_label.label = desc.to_string ();
//  
            //  Application.app.add_action_entries (ACTION_ENTRIES, this);
        }

        private void setup_binding () {
            // Application.settings.bind_with_mapping (string key, GLib.Object object, string property, GLib.SettingsBindFlags flags, GLib.SettingsBindGetMappingShared get_mapping, GLib.SettingsBindSetMappingShared set_mapping, void* user_data, GLib.DestroyNotify? notify)
            Application.settings.bind ("query-limit", query_limit, "value", SettingsBindFlags.DEFAULT);
            Application.settings.bind ("query-timeout", query_timeout, "value", SettingsBindFlags.DEFAULT);
            Application.settings.bind ("connection-timeout", conn_timeout, "value", SettingsBindFlags.DEFAULT);

            Application.settings.changed["editor-font"].connect ((_setting, key) => {

                var desc = Pango.FontDescription.from_string (_setting.get_string (key));

                font_label.get_pango_context ().set_font_description (desc);
            });
        }

        [GtkCallback]
        private void on_font_chooser (Adw.ActionRow row) {
            old_choser ();
            // new_choser ();
        }

        private void old_choser () {
            // Create dialog
            var dialog = new Gtk.FontChooserDialog (_("Select font"), this) {
                modal = true,
                transient_for = this,
                level = Gtk.FontChooserLevel.FAMILY | Gtk.FontChooserLevel.SIZE | Gtk.FontChooserLevel.STYLE,
            };

            dialog.set_filter_func ((desc) => {
                return desc.is_monospace ();
            });


            // Set font and close dialog on response
            dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.OK && dialog.font != null) {
                    font_label.get_pango_context ().set_font_description (dialog.font_desc);
                    font_label.label = dialog.font_desc.to_string ();

                    Application.settings.set_string ("editor-font", dialog.font_desc.to_string ());
                }

                dialog.close ();
            });


            /* Show dialog */
            dialog.present ();
        }

        //  private void new_choser () {
        //      var dialog = new Gtk.FontDialog () {
        //          modal = true,
        //          title = _("Select Font"),
        //      };

        //      var init = new Pango.FontDescription ();
        //      init.set_family ("Roboto Regular");
        //      init.set_size (14);

        //      dialog.choose_font.begin (this, init, null, (obj, res) => {
        //          try {
        //              var val = dialog.choose_font.end (res);
        //              font_label.get_pango_context ().set_font_description (val);
        //              font_label.label = val.get_family ();
        //          } catch (Error err) {
        //              debug (err.message);
        //          }
        //      });
        //  }

        [GtkChild]
        private unowned Gtk.Label font_label;

        [GtkChild]
        private unowned Gtk.SpinButton conn_timeout;

        [GtkChild]
        private unowned Gtk.SpinButton query_timeout;

        [GtkChild]
        private unowned Gtk.SpinButton query_limit;
    }
}