public class Ricin.Ricin : Gtk.Application {
  const string GETTEXT_PACKAGE = "ricin";
  public static const string APP_NAME = "Ricin";
  public static const string APP_SUMMARY = "<b>Ricin</b> aims to be a <i>secure, lightweight, hackable and fully-customizable</i> chat client using the awesome and open-source <b>ToxCore</b> library.";
  public static const string APP_VERSION = "0.0.3-beta";
  public static const string RES_BASE_PATH = "/chat/tox/ricin/";

  private string default_theme = "dark"; // Will be overrided by settings.

  public Ricin () {
    Object (application_id: "chat.tox.ricin",
            flags: ApplicationFlags.FLAGS_NONE); // TODO: handle open

    // Stuff for localization.
    Intl.setlocale(LocaleCategory.MESSAGES, "fr_FR");
    Intl.textdomain(GETTEXT_PACKAGE);
    Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8");
    Intl.bindtextdomain(GETTEXT_PACKAGE, "/usr/share/locale");
  }

  public override void activate () {
    string profile_dir = Tox.profile_dir ();
    string settings_file = "%s/ricin.cfg".printf (profile_dir);
    if (FileUtils.test (profile_dir, FileTest.EXISTS) == false) {
      DirUtils.create (profile_dir, 0755);
    }

    if (FileUtils.test (settings_file, FileTest.EXISTS) == false) {
      File config_file = File.new_for_path (settings_file);
      File config_sample = File.new_for_uri ("resource:///chat/tox/ricin/ricin.sample.cfg");
      config_sample.copy (config_file, FileCopyFlags.NONE);
    }

    SettingsManager settings = new SettingsManager ();

    if (settings.get_bool ("ricin.interface.enable_custom_themes") == true) {
      this.default_theme = settings.get_string ("ricin.interface.selected_theme");
      debug (@"Selected theme: $(this.default_theme)");

      // Load the default css.
      var provider = new Gtk.CssProvider ();
      provider.load_from_resource(@"$resource_base_path/themes/$(this.default_theme).css");
      Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
          provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    // Launch the notification system.
    Notify.init ("Ricin");

    // Show the login window.
    new ProfileChooser (this);
  }

  public static int main(string[] args) {
    /**
    * TODO: Fix this.
    **/
    /*if (args[1] == "--reset-settings") {
      try {
        File settings_file = File.new_for_path("%s/ricin.cfg".printf (Tox.profile_dir ()));
        settings_file.delete ();
      } catch (Error e) {
        debug (@"Error while trying to delete the settings: %s", e.message);
      }
    }*/
    return new Ricin ().run (args);
  }
}
