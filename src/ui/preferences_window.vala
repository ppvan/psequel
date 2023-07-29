namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/preferences.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {

        private Settings settings;

        public PreferencesWindow () {
            Object ();
        }

        construct {
            settings = ResourceManager.instance ().settings;
        }

        [GtkCallback]
        private void on_font_chooser (Adw.ActionRow row) {
            old_choser ();
        }

        private void old_choser () {
            /* Create dialog */
            var dialog = new Gtk.FontChooserDialog (_("Select font"), this) {
                modal = true,
                transient_for = this,
                font = "Roboto",
                level = Gtk.FontChooserLevel.SIZE,
            };

            /* Set font and close dialog on response */
            dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.OK) {
                    font_label.get_pango_context ().set_font_description (dialog.font_desc);
                    font_label.label = dialog.font_desc.to_string ();
                }

                dialog.close ();
            });

            /* Show dialog */
            dialog.present ();
        }

        private void new_choser () {
            var dialog = new Gtk.FontDialog () {
                modal = true,
                title = _("Select Font"),
            };

            var init = new Pango.FontDescription ();
            init.set_family ("Roboto Regular");
            init.set_size (14);

            dialog.choose_font.begin (this, init, null, (obj, res) => {
                var val = dialog.choose_font.end (res);

                font_label.get_pango_context ().set_font_description (val);
                font_label.label = val.get_family ();
            });
        }

        [GtkChild]
        private unowned Gtk.Label font_label;
    }
}