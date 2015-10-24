using Tox;

[GtkTemplate (ui="/chat/tox/ricin/ui/friend-list-row.ui")]
class Ricin.FriendListRow : Gtk.ListBoxRow {
  [GtkChild] public Gtk.Image avatar;
  [GtkChild] public Gtk.Label username;
  [GtkChild] Gtk.Label status;
  [GtkChild] Gtk.Image userstatus;

  public Tox.Friend fr;
  private string current_status_icon = "";
  private Gtk.Menu menu_friend;
  private Gtk.ImageMenuItem block_friend;
  private const int icon_size = 16;

  public FriendListRow (Tox.Friend fr) {
    this.fr = fr;
    if (fr.name == null) {
      this.username.set_text (this.fr.pubkey);
      this.status.set_text ("");
    }

    this.init_context_menu ();

    /**
    * Load the avatar from the avatar cache located in:
    * ~/.config/tox/avatars/
    */
    var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
    if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 48, 48, false);
      this.avatar.pixbuf = pixbuf;
    }

    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);
    fr.bind_property ("status-message", status, "label", BindingFlags.DEFAULT);
    fr.avatar.connect (p => avatar.pixbuf = p);

    fr.notify["status"].connect ((obj, prop) => {
      string icon = "";

      switch (fr.status) {
        case UserStatus.ONLINE:
          icon = "user-available-symbolic";
          break;
        case UserStatus.AWAY:
          icon = "user-away-symbolic";
          break;
        case UserStatus.BUSY:
          icon = "user-busy-symbolic";
          break;
        case UserStatus.OFFLINE:
          icon = "user-offline-symbolic";
          break;
        default:
          icon = "user-status-pending-symbolic";
          break;
      }
      this.userstatus.set_from_icon_name (icon, Gtk.IconSize.BUTTON);
      this.userstatus.set_pixel_size (this.icon_size); // Fix a weird issue.
      this.current_status_icon = this.userstatus.icon_name;
      this.changed ();
    });

    fr.notify["is-blocked"].connect ((obj, prop) => {
      this.block_friend.set_label ((this.fr.is_blocked) ? "Unblock friend" : "Block friend");
      var cur_icon = (this.current_status_icon != "") ? this.current_status_icon : "user-status-pending-symbolic";
      var icon = (this.fr.is_blocked) ? "action-unavailable-symbolic" : cur_icon;
      this.userstatus.set_from_icon_name (icon, Gtk.IconSize.BUTTON);
      this.userstatus.set_pixel_size (this.icon_size); // Fix a weird issue.
    });
  }

  private void init_context_menu () {
    debug ("Initializing context menu for friend.");

    this.button_press_event.connect (event => {
      if (event.button == Gdk.BUTTON_SECONDARY) {
        this.menu_friend.popup (null, null, null, event.button, event.time);
        return Gdk.EVENT_STOP;
      }
      return Gdk.EVENT_PROPAGATE;
    });

    this.menu_friend = new Gtk.Menu ();
    var delete_friend = new Gtk.ImageMenuItem.with_label ("Delete friend");
    var delete_friend_icon = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.MENU);
    delete_friend.always_show_image = true;
    delete_friend.set_image (delete_friend_icon);
    delete_friend.activate.connect (() => {
      var main_window = this.get_toplevel () as MainWindow;
      main_window.remove_friend (this.fr);
    });

    var block_friend_label = (this.fr.is_blocked) ? "Unblock friend" : "Block friend";
    var block_friend_icon = new Gtk.Image.from_icon_name ("action-unavailable-symbolic", Gtk.IconSize.MENU);
    this.block_friend = new Gtk.ImageMenuItem.with_label (block_friend_label);
    this.block_friend.always_show_image = true;
    this.block_friend.set_image (block_friend_icon);
    this.block_friend.activate.connect (() => {
      this.fr.is_blocked = !this.fr.is_blocked;
    });

    this.menu_friend.append (block_friend);
    this.menu_friend.append (delete_friend);
    this.menu_friend.attach_to_widget (this, null);
    this.menu_friend.show_all ();

    /*this.popup_menu.connect ((widget, event) => {
      debug ("Displaying context menu...");
      this.menu_friend.popup (null, null, null, event.button, event.time);
      return true;
    });*/
  }
}
