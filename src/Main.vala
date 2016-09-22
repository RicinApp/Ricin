using GLib;
using Gtk;
using Ricin;

class Ricin.RicinApp : Object {
  public RicinApp (string[] args) {
    /**
    * TODO: Parse OptionContext (args) and launch the app.
    * TODO: Init GetText (i18n).
    **/
  }

  public void run () {
    stdout.printf ("%s v.%s started !\n", Constants.APP_NAME, Constants.APP_VERSION);
    
    /**
    * TODO: Initialize Gtk and launch the application main window.
    **/
  }
}

/**
* Entrypoint of the application. Used to launch our RicinApp class.
**/
public static int main (string[] args) {
  RicinApp app = new RicinApp(args);
  app.run();

  return 0;
}

