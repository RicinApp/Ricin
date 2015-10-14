/*class Ricin.Notification : Object {
  private static bool initialized = false;

  // No need for constructor yet.
  private Notification () {}

  public static void notify (string title, string message, string category = "im.received") {
    if (!initialized) {
      Notify.init ("Ricin");
      initialized = true;
    }

    try {
      Notify.Notification notif = new Notify.Notification (title, message, null);
      notif.set_category (category);
      notif.show ();
    } catch (Error error) {
      print ("Error with notification:\n--- %s\n", error.message);
    }
  }
}
*/
