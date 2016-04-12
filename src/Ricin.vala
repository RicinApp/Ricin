public class Ricin.Ricin : Gtk.Application {
  const string GETTEXT_PACKAGE = "ricin";
  public static const string APP_NAME = "Ricin";
  public static const string APP_SUMMARY = _("<b>Ricin</b> aims to be a <i>secure, lightweight, hackable and fully-customizable</i> chat client using the awesome and open-source <b>ToxCore</b> library.");
  public static const string APP_VERSION = "0.0.6";
  public static const string RES_BASE_PATH = "/chat/tox/ricin/";

  private string default_theme = "dark"; // Will be overrided by settings.
  private string current_theme;
  private Settings settings;

  public Ricin () {
    Object (
      application_id: "chat.tox.ricin",
      flags: ApplicationFlags.FLAGS_NONE
    ); // TODO: handle open

    this.settings = Settings.instance;

    // Stuff for localization.
    string selected_language = this.settings.selected_language;
    try {
      Environment.set_variable ("LANG", selected_language, true);
      Intl.setlocale (LocaleCategory.MESSAGES, selected_language);
      Intl.textdomain (GETTEXT_PACKAGE);
      Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "utf-8");
      Intl.bindtextdomain (GETTEXT_PACKAGE, "/usr/share/locale");
    } catch (Error e) {
      error (@"Error initializing gettext: $(e.message)");
    }
  }

  public override void activate () {
    string profile_dir = Tox.profile_dir ();
    string avatars_dir = "%s/avatars".printf (profile_dir);
    string settings_file = "%s/ricin.json".printf (profile_dir);

    try {
      // If `$HOME/.config/tox` doesn't exists, lets create it.
      if (FileUtils.test (profile_dir, FileTest.EXISTS) == false) {
        DirUtils.create_with_parents (profile_dir, 0755);
      }

      // If `$HOME/.config/tox/avatars` doesn't exists, lets create it.
      if (FileUtils.test (avatars_dir, FileTest.EXISTS) == false) {
        DirUtils.create_with_parents (avatars_dir, 0755);
      }
    } catch (Error e) {
      error (@"Error: $(e.message)");
    }

    if (FileUtils.test (settings_file, FileTest.EXISTS) == false) {
      File config_file = File.new_for_path (settings_file);
      File config_sample = File.new_for_uri ("resource:///chat/tox/ricin/ricin.sample.json");
      config_sample.copy (config_file, FileCopyFlags.OVERWRITE);
    }

    if (this.settings.enable_custom_themes) {
      string selected_theme = this.settings.selected_theme;
      string theme_path = @"$resource_base_path/themes/";
      string theme_file = theme_path + selected_theme + ".css";

      // If theme doesn't exists apply the default one.
      if (FileUtils.test (theme_file, FileTest.EXISTS) == true) {
        this.current_theme = theme_file;
      } else {
        this.current_theme = theme_path + this.default_theme + ".css";
      }
      debug (@"Selected theme: $(this.default_theme)");

      // Load the default css.
      var provider = new Gtk.CssProvider ();
      provider.load_from_resource(this.current_theme);
      Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
          provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    // Launch the notification system.
    Notify.init ("Ricin");

    // Show the login window.
    new ProfileChooser (this);
  }

  public static int main(string[] args) {
    return new Ricin ().run (args);
  }
}
