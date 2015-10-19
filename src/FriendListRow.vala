using Tox;

[GtkTemplate (ui="/chat/tox/ricin/friend-list-row.ui")]
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
          this.userstatus.icon_name = "user-available";
          break;
        case UserStatus.AWAY:
          this.userstatus.icon_name = "user-away";
          break;
        case UserStatus.BUSY:
          this.userstatus.icon_name = "user-busy";
          break;
        default:
          this.userstatus.icon_name = "user-status-pending";
          break;
      }
    });
  }
}
