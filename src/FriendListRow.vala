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
      switch (fr.status) {
        case UserStatus.ONLINE:
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/online.png");
          break;
        case UserStatus.AWAY:
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/idle.png");
          break;
        case UserStatus.BUSY:
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/busy.png");
          break;
        case UserStatus.OFFLINE:
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/offline.png");
          break;
        default:
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/invisible.png");
          break;
      }
    });

    /**
    * TODO: Find a better way to do this.
    */
    fr.notify["unread_messages"].connect ((obj, prop) => {
      switch (fr.status) {
        case UserStatus.ONLINE:
          var icon = (fr.unread_messages) ? "online_notification" : "online";
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/" + icon + ".png");
          break;
        case UserStatus.AWAY:
          var icon = (fr.unread_messages) ? "idle_notification" : "idle";
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/" + icon + ".png");
          break;
        case UserStatus.BUSY:
          var icon = (fr.unread_messages) ? "busy_notification" : "busy";
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/" + icon + ".png");
          break;
        case UserStatus.OFFLINE:
          var icon = (fr.unread_messages) ? "offline_notification" : "offline";
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/" + icon + ".png");
          break;
        default:
          this.userstatus.set_from_resource ("/chat/tox/Ricin/assets/status/invisible.png");
          break;
      }
    });
  }
}
