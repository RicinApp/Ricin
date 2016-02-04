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

  public FriendListRow (Tox.Friend fr) {
    this.fr = fr;

    debug (@"Friend name: $(this.fr.name)");
    if (this.fr.name == null) {
      this.username.set_text (this.fr.pubkey);
      string date = this.fr.last_online ("<b>Last online:</b> %H:%M");
      this.status.set_markup (date);
    } else {
      this.username.set_text (this.fr.name);
      this.status.set_text (this.fr.status_message);
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
      string icon = Util.status_to_icon (this.fr.status, this.unreadCount);
      this.userstatus.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
      this.changed (); // we sort by user status
    });

    fr.notify["blocked"].connect ((obj, prop) => {
      this.block_friend.set_label ((this.fr.blocked) ? "Unblock friend" : "Block friend");
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

    var block_friend_label = (this.fr.blocked) ? "Unblock friend" : "Block friend";
    var block_friend_icon = new Gtk.Image.from_icon_name ("action-unavailable-symbolic", Gtk.IconSize.MENU);
    this.block_friend = new Gtk.ImageMenuItem.with_label (block_friend_label);
    this.block_friend.always_show_image = true;
    this.block_friend.set_image (block_friend_icon);
    this.block_friend.activate.connect (() => {
      this.fr.blocked = !this.fr.blocked;
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
