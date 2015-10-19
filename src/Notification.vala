class Ricin.Notification : Object {
  private static bool initialized = false;

  // No need for constructor yet.
  private Notification () {}

  public static void notify (string sender, string message, int timeout = 5000, Gdk.Pixbuf? icon = null) {
    if (!initialized) {
      Notify.init ("Ricin");
      initialized = true;
    }

    if (icon == null) {
      icon = new Gdk.Pixbuf.from_resource ("/chat/tox/ricin/images/icons/Ricin-48x48.png");
    }

    try {
      Notify.Notification notif = new Notify.Notification (sender, message, null);
      notif.set_image_from_pixbuf (icon);
      notif.set_timeout (timeout);
      notif.show ();
    } catch (Error error) {
      warning ("Error with notification:\n--- %s", error.message);
    }
  }
}
