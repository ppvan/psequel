namespace Psequel {

[GtkTemplate (ui = "/me/ppvan/psequel/gtk/style-switcher.ui")]
public class StyleSwitcher : Gtk.Widget {

  [GtkChild] unowned Gtk.CheckButton system_selector;
  [GtkChild] unowned Gtk.CheckButton light_selector;
  [GtkChild] unowned Gtk.CheckButton dark_selector;

  public uint style { get; set; }
  public bool show_system { get; set; default = true; }

  static construct {
    set_layout_manager_type (typeof (Gtk.BinLayout));
    set_css_name ("themeswitcher");
  }

  construct {
    this.notify ["style"].connect (this.on_style_changed);

    //  var s = Application.settings;
    //  s.bind_property ("style-preference",
    //                   this,
    //                   "style",
    //                   GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL,
    //                   null,
    //                   null);
  }

  private void on_style_changed () {
    this.freeze_notify ();
    if (this.style == Adw.ColorScheme.DEFAULT) {
      this.system_selector.active = true;
      this.light_selector.active = false;
      this.dark_selector.active = false;
    }
    else if (this.style == Adw.ColorScheme.FORCE_LIGHT) {
      this.system_selector.active = false;
      this.light_selector.active = true;
      this.dark_selector.active = false;
    }
    else {
      this.system_selector.active = false;
      this.light_selector.active = false;
      this.dark_selector.active = true;
    }
    this.thaw_notify ();
  }

  [GtkCallback]
  private void theme_check_active_changed () {
    if (this.system_selector.active) {
      if (this.style != Adw.ColorScheme.DEFAULT) {
        this.style = (uint) Adw.ColorScheme.DEFAULT;
      }
    }
    else if (this.light_selector.active) {
      if (this.style != Adw.ColorScheme.FORCE_LIGHT) {
        this.style = (uint) Adw.ColorScheme.FORCE_LIGHT;
      }
    }
    else {
      if (this.style != Adw.ColorScheme.FORCE_DARK) {
        this.style = (uint) Adw.ColorScheme.FORCE_DARK;
      }
    }
  }
}

}