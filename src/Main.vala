using ToxCore;
using Gtk;
using Ricin;
using Ricin.Utils;

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
    private bool debug = false;
    private string profile = null;
    private bool show_version = false;
    private const OptionEntry[] options = {
      { "enable-debug", "d", 0, OptionArg.NONE, ref this.debug, "Run Ricin in debug mode." , null },
      { "profile", "p", 0, OptionArg.STRING, ref this.profile, "Profile name|path to load.", "NAME|PATH" },
      { "version", "v", 0, OptionArg.NONE, ref this.show_version, "Displays the Ricin version.", null },
      { null } // List terminator.
    };

    public RicinApp () {
      /**
      * TODO: Init GetText (i18n).
      **/
    }

    public void run () {
      print ("Running ToxCore version %u.%u.%u\n", ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH);
      print ("%s version %s started !\n", Constants.APP_NAME, Constants.APP_VERSION);

      try {
        Options options = new Options (null);
        options.ipv6_enabled = true;
        options.udp_enabled = true;
        options.proxy_type = ProxyType.NONE;

        this.handle = new ToxSession (null, options);
      } catch (ErrNew e) {
        error (@"Ricin wasn't able to start a new ToxSession, error: $(e.message)");
      }

      this.handle.tox_run_loop (); // Run toxcore instance.
      this.loop.run (); // Run the main loop.

      /**
      * TODO: Initialize Gtk and launch the application main window.
      **/
    }

    private void parse_args (ref string[] args) {
      /**
      * TODO: Parse arguments and handle them.
      **/
      try {
        var opt_context = new OptionContext ("- Ricin: A dead simple, privacy oriented, instant messaging client!");
        opt_context.set_help_enabled (true);
        opt_context.add_main_entries (this.options, null);
        opt_context.parse (ref args);
      } catch (Error e) {
        stdout.printf ("Error: %s\n", e.message);
        stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
        return 1;
      }

      if (this.show_version) {
        stdout.printf ("%s version %s", Constants.APP_NAME, Constants.APP_VERSION);
        return 0;
      }
    }
  }
}

/**
* Entrypoint of the application. Used to launch our RicinApp class.
**/
public static int main (string[] args) {
  RicinApp app = new RicinApp ();
  app.parse_args (ref args);
  app.run ();

  return 0;
}
