using Tox;

[GtkTemplate (ui="/chat/tox/ricin/ui/friend-list-row.ui")]
class Ricin.FriendListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Image avatar;
  [GtkChild] public Gtk.Label username;
  [GtkChild] Gtk.Label status;
  [GtkChild] Gtk.Image userstatus;

  public Tox.Friend fr;

  public FriendListRow (Tox.Friend fr) {
    this.fr = fr;

    /**
    * Load the avatar from the avatar cache located in:
    * ~/.config/tox/avatars/
    */
    var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
    if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 46, 46, true);
      this.avatar.pixbuf = pixbuf;
    }

    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);
    fr.bind_property ("status-message", status, "label", BindingFlags.DEFAULT);
    fr.avatar.connect (p => avatar.pixbuf = p);
    fr.notify["connected"].connect ((obj, prop) => {
      if (!fr.connected) {
      	this.userstatus.icon_name = "user-offline";
        this.changed ();
      }
    });

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
      this.changed ();
    });
  }
}
