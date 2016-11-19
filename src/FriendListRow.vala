using Tox;

[GtkTemplate (ui="/chat/tox/ricin/ui/friend-list-row.ui")]
class Ricin.FriendListRow : Gtk.ListBoxRow {
  [GtkChild] public Gtk.Image avatar;
  [GtkChild] public Gtk.Box box_infos;
  [GtkChild] public Gtk.Label username;
  [GtkChild] Gtk.Label status;
  [GtkChild] Gtk.Label label_unread_count;
  [GtkChild] Gtk.Image userstatus;

  public Tox.Friend fr;
  public weak Tox.Group group;

  private string current_status_icon = "";
  private Gtk.Menu menu_friend;
  private Gtk.ImageMenuItem block_friend;

  private Settings settings;
  private ViewType view_type;
  private string iconName = "offline";
  private Gdk.Pixbuf pixbuf;

  public string view_name;
  public int unreadCount = 0;

  private enum ViewType {
    FULL,
    COMPACT
  }

  public FriendListRow (Tox.Friend fr) {
    this.fr = fr;
    this.settings = Settings.instance;
    this.view_name = "chat-%s".printf (fr.pubkey);

    debug (@"Friend name: $(this.fr.name)");
    if (this.fr.name == null) {
      if (this.fr.get_uname () == null) {
        this.username.set_text (this.fr.pubkey);
      } else {
        this.username.set_text (Util.escape_html (this.fr.get_uname ()));
      }
      this.status.set_markup (Util.escape_html (this.fr.get_ustatus_message ()));
      this.status.set_tooltip_markup (Util.escape_html (this.fr.get_ustatus_message ()));
    } else {
      this.username.set_text (Util.escape_html (this.fr.name));
      this.status.set_text (Util.escape_html (this.fr.status_message));
      this.status.set_tooltip_markup (Util.escape_html (this.fr.status_message));
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
    } else {
      Cairo.Surface surface = Util.identicon_for_pubkey (fr.pubkey);
      this.avatar.pixbuf = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
    }
    this.pixbuf = this.avatar.pixbuf;

    if (this.settings.compact_mode) {
      this.switch_view_type (ViewType.COMPACT);
    }
    this.settings.notify["compact-mode"].connect (() => {
      if (this.settings.compact_mode) {
        this.switch_view_type (ViewType.COMPACT);
      } else {
        this.switch_view_type (ViewType.FULL);
      }
    });

    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);
    //fr.bind_property ("status-message", status, "label", BindingFlags.DEFAULT);
    fr.avatar.connect (p => avatar.pixbuf = p);

    fr.notify["status-message"].connect ((obj, prop) => {
      this.status.set_text (this.fr.status_message);
      this.status.set_tooltip_markup (this.fr.status_message);
    });

    fr.notify["status"].connect ((obj, prop) => {
      if (this.settings.enable_notify_status && this.fr.status != this.fr.last_status) {
        Notification.notify_status (fr);
      }

      string icon = Util.status_to_icon (this.fr.status, 0);
      this.userstatus.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
      this.changed (); // we sort by user status
    });

    fr.notify["blocked"].connect ((obj, prop) => {
      this.block_friend.set_label ((this.fr.blocked) ? _("Unblock friend") : _("Block friend"));
    });

    fr.avatar.connect ((pixbuf_avatar) => {
      this.pixbuf = pixbuf_avatar;
      this.switch_view_type (this.view_type);
    });

    fr.message.connect (() => {
      this.notify_new_messages ();
    });
    fr.action.connect (() => {
      this.notify_new_messages ();
    });
    fr.file_transfer.connect (() => {
      this.notify_new_messages ();
    });

    this.activate.connect (() => {
      var main_window = ((MainWindow) this.get_toplevel ());
      main_window.global_unread_counter -= this.unreadCount;

      this.unreadCount = 0;
      this.update_icon ();
      this.changed ();

      main_window.friendlist.invalidate_filter ();
      main_window.grouplist.invalidate_filter ();
    });
  }

  public FriendListRow.groupchat (Tox.Group group) {
    this.settings = Settings.instance;
    this.view_name = "group-%d".printf (group.id);
    this.group = group;

    this.username.set_text (this.group.name);
    this.username.set_tooltip_text (this.group.name);
    this.status.set_text (_("%d peers").printf (this.group.peers_count));
    //this.status.set_text ("Peers: 0");
    this.userstatus.visible = false;
    Cairo.Surface surface = Util.identicon_for_pubkey (this.group.name);
    this.avatar.pixbuf = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
    this.pixbuf = this.avatar.pixbuf;

    if (this.settings.compact_mode) {
      this.switch_view_type (ViewType.COMPACT);
    }
    this.settings.notify["compact-mode"].connect (() => {
      if (this.settings.compact_mode) {
        this.switch_view_type (ViewType.COMPACT);
      } else {
        this.switch_view_type (ViewType.FULL);
      }
    });

    this.group.peer_count_changed.connect ((peer) => {
      this.status.set_text (_("%d peers").printf (this.group.peers_count - 1));
    });

    this.group.title_changed.connect ((peer_num, title) => {
      this.username.set_text (this.group.name);
      this.username.set_tooltip_text (this.group.name);
      //this.status.set_text (_("Peers: %d", this.group.peers.length ()));
      if (this.view_type == ViewType.COMPACT) {
        Cairo.Surface s = Util.identicon_for_pubkey (this.group.name, 24);
        this.avatar.pixbuf = Gdk.pixbuf_get_from_surface (s, 0, 0, 24, 24);
      } else {
        Cairo.Surface s = Util.identicon_for_pubkey (this.group.name, 48);
        this.avatar.pixbuf = Gdk.pixbuf_get_from_surface (s, 0, 0, 48, 48);
      }
      this.pixbuf = this.avatar.pixbuf;
    });

    this.group.message.connect (() => {
      this.notify_new_messages ();
    });
    this.group.action.connect (() => {
      this.notify_new_messages ();
    });

    this.activate.connect (() => {
      var main_window = ((MainWindow) this.get_toplevel ());
      main_window.global_unread_counter -= this.unreadCount;

      this.unreadCount = 0;
      this.update_icon ();
      this.changed ();

      main_window.friendlist.invalidate_filter ();
      main_window.grouplist.invalidate_filter ();
    });
  }

  public void update_icon () {
    /*string icon = Util.status_to_icon (this.fr.status, this.unreadCount);
    this.userstatus.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");*/

    if (this.unreadCount == 0) {
      this.label_unread_count.visible = false;
    } else {
      string count_str = this.unreadCount > 90 ? "<b>90+</b>" : @"$(this.unreadCount)";

      this.label_unread_count.set_markup (count_str);
      this.label_unread_count.visible = true;
    }
  }

  private void notify_new_messages () {
    var main_window = ((MainWindow) this.get_toplevel ());
    if (main_window.focused_view == this.view_name) {
      return;
    }
    
    if (this.group.muted) {
      return;
    }

    this.unreadCount++;
    main_window.global_unread_counter += this.unreadCount;
    this.update_icon ();
  }

  private void switch_view_type (ViewType type) {
    if (type == ViewType.FULL) {
      this.set_size_request (100, 60);

      this.avatar.pixbuf = this.pixbuf;
      this.avatar.set_pixel_size (48);
      this.avatar.set_size_request (48, 48);

      this.box_infos.set_orientation (Gtk.Orientation.VERTICAL);
      this.box_infos.set_valign (Gtk.Align.FILL);
      this.box_infos.set_halign (Gtk.Align.FILL);

      this.username.set_vexpand (true);
      this.username.set_hexpand (true);
      this.username.set_margin_top (7);
      this.username.set_valign (Gtk.Align.FILL);

      this.status.set_margin_bottom (7);
      this.status.set_valign (Gtk.Align.END);
      this.status.set_halign (Gtk.Align.START);
    } else if (type == ViewType.COMPACT) {
      this.set_size_request (100, 30);

      this.avatar.pixbuf = this.avatar.pixbuf.scale_simple (24, 24, Gdk.InterpType.BILINEAR);
      this.avatar.set_pixel_size (24);
      this.avatar.set_size_request (24, 24);

      this.box_infos.set_orientation (Gtk.Orientation.HORIZONTAL);
      this.box_infos.set_valign (Gtk.Align.CENTER);
      this.box_infos.set_halign (Gtk.Align.START);

      this.username.set_vexpand (false);
      this.username.set_hexpand (false);
      this.username.set_margin_top (0);
      this.username.set_valign (Gtk.Align.CENTER);

      this.status.set_margin_bottom (0);
      this.status.set_valign (Gtk.Align.CENTER);

      if (this.view_name.index_of ("group") != -1) {
        this.username.set_vexpand (true);
        this.status.set_halign (Gtk.Align.END);
        this.box_infos.set_halign (Gtk.Align.FILL);
      }
    }

    this.view_type = type;
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

    // Open friend profile.
    var open_friend_profile = new Gtk.ImageMenuItem.with_label (_("Friend's profile"));
    var open_friend_profile_icon = new Gtk.Image.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.MENU);
    open_friend_profile.always_show_image = true;
    open_friend_profile.set_image (open_friend_profile_icon);
    open_friend_profile.activate.connect (() => {
      var main_window = this.get_toplevel () as MainWindow;
      main_window.open_profile (this.fr);
    });

    // Copy friend ToxID.
    var copy_friend_toxid = new Gtk.ImageMenuItem.with_label (_("Copy friend's ToxID"));
    var copy_friend_toxid_icon = new Gtk.Image.from_icon_name ("edit-copy-symbolic", Gtk.IconSize.MENU);
    copy_friend_toxid.always_show_image = true;
    copy_friend_toxid.set_image (copy_friend_toxid_icon);
    copy_friend_toxid.activate.connect (() => {
      Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (this.fr.pubkey, -1);
    });

    // Delete friend action.
    var delete_friend = new Gtk.ImageMenuItem.with_label (_("Delete"));
    var delete_friend_icon = new Gtk.Image.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.MENU);
    delete_friend.always_show_image = true;
    delete_friend.set_image (delete_friend_icon);
    delete_friend.activate.connect (() => {
      var main_window = this.get_toplevel () as MainWindow;
      main_window.remove_friend (this.fr);
    });

    // Block friend action.
    var block_friend_label = (this.fr.blocked) ? _("Unblock") : _("Block");
    var block_friend_icon = new Gtk.Image.from_icon_name ("dialog-error-symbolic.symbolic", Gtk.IconSize.MENU);
    this.block_friend = new Gtk.ImageMenuItem.with_label (block_friend_label);
    this.block_friend.always_show_image = true;
    this.block_friend.set_image (block_friend_icon);
    this.block_friend.activate.connect (() => {
      var main_window = this.get_toplevel () as MainWindow;
      var view = main_window.chat_stack.get_child_by_name ("chat-%s".printf (this.fr.pubkey));
      ((ChatView) view).block_friend ();
    });

    this.menu_friend.append (open_friend_profile);
    this.menu_friend.append (copy_friend_toxid);
    this.menu_friend.append (new Gtk.SeparatorMenuItem ());
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
