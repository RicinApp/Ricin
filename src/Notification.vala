using Gdk; // required by Pixbuf

class Ricin.Notification : Object {
  private static bool initialized = false;

  // No need for constructor yet.
  private Notification () {}

  public static void notify (string sendeur, string message) {
    /*
    sendeur == envoyeur
    message == message
    */
    if (!initialized) {
      Notify.init ("Ricin");
      initialized = true;
    }

    Pixbuf icon = new Pixbuf.from_file("../res/icon.png"); // path to icon.png

    try {
      Notify.Notification notif = new Notify.Notification (sendeur, message, null);
      notif.set_image_from_pixbuf (icon);
      notif.show ();
    } catch (Error error) {
      print ("Error with notification:\n--- %s\n", error.message);
    }
  }
}
