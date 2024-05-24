using Gtk;
using Adw;
using GtkSource;

namespace Psequel {
[GtkTemplate(ui = "/me/ppvan/psequel/gtk/where-entry.ui")]
public class WhereEntry : Gtk.Box {
    //  private GtkSource.

    private LanguageManager lang_manager;
    private StyleSchemeManager style_manager;
    private Application app;


    public WhereEntry() {
        Object();
    }

    construct {
        this.app = autowire<Application>();
        default_setttings();

        this.buffer.insert_text.connect((ref pos, text, len) => {
            if (text == "\n") {
                Signal.stop_emission_by_name(this.buffer, "insert_text");
            }

        });
    }


    [GtkCallback]
    private async void filter_query(Gtk.Button btn) {
    }

    //  [GtkCallback]
    //  private void on_filter_changed(Gtk.Editable entry) {

    //  }

    private void default_setttings() {
        lang_manager  = LanguageManager.get_default();
        style_manager = StyleSchemeManager.get_default();
        var lang = lang_manager.get_language("sql");
        buffer.language = lang;


        app.style_manager.bind_property("dark", buffer, "style_scheme", BindingFlags.SYNC_CREATE, (binding, from, ref to) => {
                var is_dark = from.get_boolean();
                if (is_dark)
                {
                    var scheme = style_manager.get_scheme("Adwaita-dark");
                    to.set_object(scheme);
                }
                else
                {
                    var scheme = style_manager.get_scheme("Adwaita");
                    to.set_object(scheme);
                }

                return(true);
            });
    }

    [GtkChild]
    private unowned GtkSource.Buffer buffer;

    [GtkChild]
    private unowned GtkSource.View editor;
}
}
