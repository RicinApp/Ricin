using ToxCore;
using Gtk;
using Ricin;
using Ricin.Core;
using Ricin.Utils;
using Ricin.Utils.Logger;

namespace Ricin {
  class RicinApp : Object {
    /**
    * Let's keep an instance of ToxSession for the test.
    **/
    private ToxSession handle { get; set; default = null; }

    /**
    * Define a new GLib.MainLoop to avoid app to exit.
    **/
    private MainLoop loop = new MainLoop ();

    /**
    * Defines our option context values.
    **/
    private static bool debug = false;
    private static string profile = null;
    private static bool show_version = false;
    private const OptionEntry[] options = {
      { "enable-debug", 'd', 0, OptionArg.NONE, ref debug, "Run Ricin in debug mode." , null },
      { "profile", 'p', 0, OptionArg.STRING, ref profile, "Profile name OR path to load.", "[name/path]" },
      { "version", 'v', 0, OptionArg.NONE, ref show_version, "Displays the Ricin version.", null },
      { null } // List terminator.
    };

    /**
    * Main app constructor. Init GetText, declare application_id, etc...
    **/
    public RicinApp () {
      //Object (application_id: "im.ricin.messenger", flags: ApplicationFlags.FLAGS_NONE); // TODO: Handle open.

      Intl.setlocale (LocaleCategory.MESSAGES, "");
      Intl.textdomain (Constants.GETTEXT_PACKAGE);
      Intl.bind_textdomain_codeset (Constants.GETTEXT_PACKAGE, "utf-8");
      Intl.bindtextdomain (Constants.GETTEXT_PACKAGE, "./data/languages"); // For debug.

      RInfo (_("This is a sentence in English."));
    }

    /**
    * Parse arguments given to the app.
    * @param {string[]} args - The array of arguments.
    **/
    public int parse_args (string[] args) {
      /**
      * TODO: Parse arguments and handle them.
      **/
      try {
        var opt_context = new OptionContext ("- Ricin: A dead simple, privacy oriented, instant messaging client!");
        opt_context.set_help_enabled (true);
        opt_context.add_main_entries (options, null);
        opt_context.parse (ref args);
      } catch (Error e) {
        RError ("Error: %s", e.message);
        RInfo ("Run '%s --help' to see a full list of available command line options.", args[0]);
        return 1;
      }

      if (show_version) {
        RInfo ("%s version %s", Constants.APP_NAME, Constants.APP_VERSION);
        return 0;
      }

      return -1;
    }

    /**
    * This methods permits to run the app.
    **/
    public void run () {
      RInfo ("%s version %s started !", Constants.APP_NAME, Constants.APP_VERSION);
      RInfo ("Running ToxCore version %u.%u.%u", ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH);

      try {
        Options options = new Options (null);
        options.ipv6_enabled = true;
        options.udp_enabled = true;
        options.proxy_type = ProxyType.NONE;

        this.handle = new ToxSession (null, options);
      } catch (ErrNew e) {
        RError (@"Ricin wasn't able to start a new ToxSession, error: $(e.message)");
        return;
      }

      /**
      * Temp code to auto-accept friend requests.
      **/
      this.handle.contact_request.connect ((request) => {
        request.accept ();
      });

      this.handle.tox_run_loop (); // Run toxcore instance.
      this.loop.run (); // Run the main loop.

      /**
      * TODO: Initialize Gtk and launch the application main window.
      **/
    }
  }
}

/**
* Entrypoint of the application. Used to launch our RicinApp class.
**/
public static int main (string[] args) {
  RicinApp app = new RicinApp ();
  int parse = app.parse_args (args);
  if (parse != -1) {
    return parse;
  }
  app.run ();

  return 0;
}
