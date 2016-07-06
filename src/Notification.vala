class Ricin.Notification : Object {
  public static new void notify (string sender, string message, int timeout = 5000, Gdk.Pixbuf? icon = null) {
    try {
      Notify.Notification notif;

      if (icon == null) {
        notif = new Notify.Notification (sender, message, "dialog-information");
      } else {
        notif = new Notify.Notification (sender, message, null);
        notif.set_image_from_pixbuf (icon);
      }
      
      notif.set_category ("im.received");
      notif.set_hint ("sound-name", new Variant.string ("message-new-instant"));
      notif.set_timeout (timeout);
      notif.show ();
    } catch (Error error) {
      warning ("Notification error: %s", error.message);
    }
  }
}
