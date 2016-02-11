class ThemeManager : GLib.Object {
  private static ThemeManager? _instance;
  public static ThemeManager instance {
    get {
      if(_instance == null) {
        _instance = new ThemeManager ();
      }
      return _instance;
    }
    private set {
      _instance = value;
    }
  }

  public string custom_themes_base_path = "/chat/tox/ricin";
  public string system_theme;
  public string current_theme_name = "default";

  public ThemeManager () {

  }

  private void add_provider (Gtk.CssProvider provider) {
    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
        provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
  }

  public void get_themes_list () {

  }

  public void set_theme (string name) {
    this.current_theme_name = "%s".printf (name);

    debug (@"Theme name: $(this.current_theme_name)");

    var provider = new Gtk.CssProvider ();
    provider.load_from_resource(@"$(this.custom_themes_base_path)/themes/$(this.current_theme_name).css");
    this.add_provider (provider);
  }

  public void set_system_theme () {
    Gtk.Settings settings = Gtk.Settings.get_default ();
    this.system_theme = "%s".printf (settings.gtk_theme_name);
    this.current_theme_name = this.system_theme;
    var provider = Gtk.CssProvider.get_named (this.system_theme, null);
    this.add_provider (provider);
  }

  public void reload_theme () {
    if (this.current_theme_name != this.system_theme) {
      debug (@"Theme set: $(this.current_theme_name)");
      this.set_theme (this.current_theme_name);
    } else {
      debug (@"Theme set: system");
      this.set_system_theme ();
    }
  }
}
