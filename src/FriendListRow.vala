using Tox;

[GtkTemplate (ui="/chat/tox/Ricin/friend-list-row.ui")]
class Ricin.FriendListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Image avatar;
  [GtkChild] Gtk.Label username;
  [GtkChild] Gtk.Label status;
  [GtkChild] Gtk.Image userstatus;

  public Tox.Friend fr;

  public FriendListRow (Tox.Friend fr) {
    this.fr = fr;
    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);
    fr.bind_property ("status-message", status, "label", BindingFlags.DEFAULT);
    fr.notify["status"].connect ((obj, prop) => {
      var icon = "";
      switch (fr.status) {
        case UserStatus.ONLINE:
          icon = (fr.unread_messages) ? "online_notification" : "online";
          break;
        case UserStatus.AWAY:
          icon = (fr.unread_messages) ? "idle_notification" : "idle";
          break;
        case UserStatus.BUSY:
          icon = (fr.unread_messages) ? "busy_notification" : "busy";
          break;
        case UserStatus.OFFLINE:
          icon = (fr.unread_messages) ? "offline_notification" : "offline";
          break;
      }

      this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/" + icon + ".png");
    });

    /**
    * TODO: Find a better way to do this.
    */
    fr.notify["unread_messages"].connect ((obj, prop) => {
      debug ("Unread messages ? %s", (string) fr.unread_messages);

      var icon = "";
      switch (fr.status) {
        case UserStatus.ONLINE:
          icon = (fr.unread_messages) ? "online_notification" : "online";
          break;
        case UserStatus.AWAY:
          icon = (fr.unread_messages) ? "idle_notification" : "idle";
          break;
        case UserStatus.BUSY:
          icon = (fr.unread_messages) ? "busy_notification" : "busy";
          break;
        case UserStatus.OFFLINE:
          icon = (fr.unread_messages) ? "offline_notification" : "offline";
          break;
      }

      this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/" + icon + ".png");
    });
  }
}
