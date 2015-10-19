class Ricin.Notification : Object {
  private static bool initialized = false;

  // No need for constructor yet.
  private Notification () {}

  public static void notify (string sender, string message, int timeout = 5000, Gdk.Pixbuf? icon = null) {
    if (!initialized) {
      Notify.init ("Ricin");
      initialized = true;
    }

    try {
      Notify.Notification notif;

      if (icon == null) {
        notif = new Notify.Notification (sender, message, "dialog-information");
      } else {
        notif = new Notify.Notification (sender, message, null);
        notif.set_image_from_pixbuf (icon);
      }
      notif.set_category("im.received");
      notif.set_hint("sound-name", new Variant.string("message-new-instant"));
      notif.set_timeout (timeout);
      notif.show ();
    } catch (Error error) {
      warning ("Error with notification:\n--- %s", error.message);
    }
  }
}
