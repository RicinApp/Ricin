using GLib;
using Gtk;
using Ricin;
using ToxCore;

class Ricin.RicinApp : Object {
  /**
  * Let's keep an instance of ToxSession for the test.
  **/
  private ToxSession handle { get; set; default = null; }

  /**
  * Define a new GLib.MainLoop to avoid app to exit.
  **/
  private MainLoop loop = new MainLoop ();

  public RicinApp (string[] args) {
    /**
    * TODO: Parse OptionContext (args) and launch the app.
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
}

/**
* Entrypoint of the application. Used to launch our RicinApp class.
**/
public static int main (string[] args) {
  RicinApp app = new RicinApp (args);
  app.run ();

  return 0;
}

