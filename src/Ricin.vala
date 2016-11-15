public class Ricin.Ricin : Gtk.Application {
  const string GETTEXT_PACKAGE = "ricin";
  public static const string APP_NAME = "Ricin";
  public static const string APP_SUMMARY = "<b>Ricin</b> aims to be a <i>secure, lightweight, hackable and fully-customizable</i> chat client using the awesome and open-source <b>ToxCore</b> library.";
  public static const string APP_VERSION = "0.2.9";
  public static const string RES_BASE_PATH = "/chat/tox/ricin/";
  public static const string ICON_PATH = RES_BASE_PATH + "images/icons/ricin.svg";

  private string default_theme = "tox"; // Will be overrided by settings.
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
    } catch (Error e) {
      // Fallback to native language.
      Intl.textdomain (GETTEXT_PACKAGE);
      Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "utf-8");
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

    /*if (FileUtils.test (settings_file, FileTest.EXISTS) == false) {
      File config_file = File.new_for_path (settings_file);
      File config_sample = File.new_for_uri (@"$resource_base_path/ricin.sample.json");
      config_sample.copy (config_file, FileCopyFlags.OVERWRITE);
    }*/

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
      provider.load_from_resource ("/chat/tox/ricin/themes/styles.css"); // Load default css helpers.
      provider.load_from_resource (this.current_theme);
      Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
          provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    } else {
      var provider = new Gtk.CssProvider ();
      provider.load_from_resource ("/chat/tox/ricin/themes/styles.css"); // Load default css helpers.
      Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
          provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    if (this.settings.default_save_path == "") {
      string path = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
      this.settings.default_save_path = path;
    }

    // Launch the notification system.
    Notify.init ("Ricin");

    // Show the login window.
    new ProfileChooser (this);
  }

  // OptionContext: Permits to handle commands the proper way.
  private static bool version = false;
  private const GLib.OptionEntry[] OPTIONS = {
    { "version", 'v', 0, OptionArg.NONE, ref version, "Display the Ricin version", null },
    { null } // List terminator
  };

  public static int main (string[] args) {
    try {
      var opt_context = new OptionContext ("- Ricin instant messaging Tox client");
      opt_context.set_help_enabled (true);
      opt_context.add_main_entries (OPTIONS, null);
      opt_context.parse (ref args);
    } catch (OptionError e) {
      stdout.printf ("error: %s\n", e.message);
      stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
      return 0;
    }

    /**
    * Display Ricin + libs versions.
    **/
    if (version) {
      print (@"$APP_NAME version $APP_VERSION\n");

      string[] libtoxcore = {
        "%u".printf (ToxCore.Version.MAJOR),
        "%u".printf (ToxCore.Version.MINOR),
        "%u".printf (ToxCore.Version.PATCH)
      };
      print ("libtoxcore version ".concat (string.joinv (".", libtoxcore), "\n"));

      /**
      * TODO: uncomment this when libtoxav got used.
      * string[] libtoxav = {
      *   "%u".printf (ToxAV.Version.MAJOR),
      *   "%u".printf (ToxAV.Version.MINOR),
      *   "%u".printf (ToxAV.Version.PATCH)
      * };
      * print ("libtoxav version ".concat (string.joinv (".", toxcore), "\n"));
      **/

      string[] glib = {
        "%u".printf (GLib.Version.MAJOR),
        "%u".printf (GLib.Version.MINOR),
        "%u".printf (GLib.Version.MICRO)
      };
      print ("GLib version ".concat (string.joinv (".", glib), "\n"));
      string[] gtk = {
        "%u".printf (Gtk.MAJOR_VERSION),
        "%u".printf (Gtk.MINOR_VERSION),
        "%u".printf (Gtk.MICRO_VERSION)
      };
      print ("GTK+3 version ".concat (string.joinv (".", gtk), "\n"));
      string[] libnotify = {
        "%u".printf (Notify.VERSION_MAJOR),
        "%u".printf (Notify.VERSION_MINOR),
        "%u".printf (Notify.VERSION_MICRO)
      };
      print ("libnotify version ".concat (string.joinv (".", libnotify), "\n"));
      string[] jsonglib = {
        "%u".printf (Json.MAJOR_VERSION),
        "%u".printf (Json.MINOR_VERSION),
        "%u".printf (Json.MICRO_VERSION)
      };
      print ("json-glib version ".concat (string.joinv (".", jsonglib), "\n"));

      return 0;
    }

    return new Ricin ().run (args);
  }
}
