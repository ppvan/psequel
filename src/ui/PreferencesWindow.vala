namespace Psequel {
// valalint=skip-file
    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/preferences-window.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        // const ActionEntry[] ACTION_ENTRIES = {
        // { "editor-font", old_choser },
        // };

        private Settings ? settings;

        public PreferencesWindow () {
            Object ();
        }

        construct {
            this.settings = autowire<Settings> ();
            setup_binding ();
            defaults ();
        }


        private void defaults () {
            var desc = Pango.FontDescription.from_string (settings.get_string ("editor-font"));

            font_label.get_pango_context ().set_font_description (desc);
            font_label.label = desc.to_string ();
//
            // Application.app.add_action_entries (ACTION_ENTRIES, this);
        }

        private void setup_binding () {
            // settings.bind_with_mapping (string key, GLib.Object object, string property, GLib.SettingsBindFlags flags, GLib.SettingsBindGetMappingShared get_mapping, GLib.SettingsBindSetMappingShared set_mapping, void* user_data, GLib.DestroyNotify? notify)
            settings.bind ("query-limit", query_limit, "value", SettingsBindFlags.DEFAULT);
            settings.bind ("query-timeout", query_timeout, "value", SettingsBindFlags.DEFAULT);
            settings.bind ("connection-timeout", conn_timeout, "value", SettingsBindFlags.DEFAULT);

            settings.changed["editor-font"].connect ((_setting, key) => {
                var desc = Pango.FontDescription.from_string (_setting.get_string (key));

                font_label.get_pango_context ().set_font_description (desc);
            });
        }

        [GtkCallback]
        private void on_font_chooser (Adw.ActionRow row) {
            var dialog = new Gtk.FontDialog () {
                modal = true,
                title = _("Select Font")
            };
            dialog.filter = new MonospaceFilter ();

            var current_font = Pango.FontDescription.from_string (settings.get_string ("editor-font"));

            dialog.choose_font.begin (this, current_font, null, (obj, res) => {
                try {
                    Pango.FontDescription val = dialog.choose_font.end (res);
                    font_label.get_pango_context ().set_font_description (val);
                    font_label.label = val.to_string ();
                    settings.set_string ("editor-font", val.to_string ());
                } catch (Error err) {
                    debug (err.message);
                }
            });
        }

        // private void new_choser () {
        // var dialog = new Gtk.FontDialog () {
        // modal = true,
        // title = _("Select Font"),
        // };

        // var init = new Pango.FontDescription ();
        // init.set_family ("Roboto Regular");
        // init.set_size (14);

        // dialog.choose_font.begin (this, init, null, (obj, res) => {
        // try {
        // var val = dialog.choose_font.end (res);
        // font_label.get_pango_context ().set_font_description (val);
        // font_label.label = val.get_family ();
        // } catch (Error err) {
        // debug (err.message);
        // }
        // });
        // }

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
