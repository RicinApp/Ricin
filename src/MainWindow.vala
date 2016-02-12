[GtkTemplate (ui="/chat/tox/ricin/ui/main-window.ui")]
public class Ricin.MainWindow : Gtk.ApplicationWindow {
  // User profile.
  [GtkChild] Gtk.Image avatar_image;
  [GtkChild] Gtk.Entry entry_name;
  [GtkChild] Gtk.Entry entry_status;
  [GtkChild] Gtk.Button button_user_status;
  [GtkChild] Gtk.Image image_user_status;

  // Search + filter.
  [GtkChild] Gtk.SearchEntry searchentry_friend;
  [GtkChild] Gtk.ComboBoxText combobox_friend_filter;

  // Friendlist + chatview.
  [GtkChild] Gtk.ListBox friendlist;
  [GtkChild] public Gtk.Stack chat_stack;

  // Add friend revealer.
  [GtkChild] public Gtk.Button button_add_friend_show;
  [GtkChild] public Gtk.Revealer add_friend;
  [GtkChild] public Gtk.Entry entry_friend_id;
  [GtkChild] Gtk.TextView entry_friend_message;
  [GtkChild] Gtk.Label label_add_error;

  // System notify.
  [GtkChild] public Gtk.Revealer revealer_system_notify;
  [GtkChild] public Gtk.Label label_system_notify;

  // Settings button.
  [GtkChild] Gtk.Button button_settings;

  private ListStore friends = new ListStore (typeof (Tox.Friend));

  public Tox.Tox tox;
  public string focused_view;
  private Gtk.Menu menu_statusicon_main;
  private Gtk.StatusIcon statusicon_main;

  public signal void notify_message (string message, int timeout = 5000);

  private string avatar_path () {
    return Tox.profile_dir () + "avatars/" + this.tox.pubkey + ".png";
  }

  /**
  * This is the sort method used for sorting contacts based on:
  * Contact is online (top) → Contact is offline (end)
  * Contact status: Online → Away → Busy → Blocked → Offlines with name → Offlines without name.
  */
  public static int sort_friendlist_online (Gtk.Widget row1, Gtk.Widget row2) {
    var friend1 = (row1 as FriendListRow);
    var friend2 = (row2 as FriendListRow);


    if (friend1.fr.status != Tox.UserStatus.OFFLINE && friend2.fr.status == Tox.UserStatus.OFFLINE) {
      return -1;
    } else if (friend1.fr.status == Tox.UserStatus.OFFLINE && friend2.fr.status != Tox.UserStatus.OFFLINE) {
      return 1;
    } else if (friend1.fr.status != Tox.UserStatus.OFFLINE && friend2.fr.status != Tox.UserStatus.OFFLINE) {
      if (friend1.fr.blocked && !friend2.fr.blocked) {
        return 1;
      }
      return friend1.fr.status - friend2.fr.status;
      //return friend1.fr.name  friend2.fr.name;
    }
    return friend1.fr.status - friend2.fr.status;
  }

  public void remove_friend (Tox.Friend fr) {
    //var friend = (this.friends.get_object (fr.num) as Tox.Friend);
    var friend = fr;
    var name = friend.get_uname ();
    var dialog = new Gtk.MessageDialog (this,
                                        Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
                                        @"Are you sure you want to delete \"$name\"?");
    dialog.secondary_text = @"This will remove \"$name\" and the chat history with it forever.";
    dialog.add_buttons ("Yes", Gtk.ResponseType.ACCEPT, "No", Gtk.ResponseType.REJECT);
    dialog.response.connect (response => {
      if (response == Gtk.ResponseType.ACCEPT) {
        bool result = friend.delete ();
        if (result) {
          this.friends.remove (friend.num);
          this.tox.save_data ();
        }
      }

      dialog.destroy ();
    });

    dialog.show ();
  }

  public MainWindow (Gtk.Application app, string profile) {
    Object (application: app);

    this.set_size_request (920, 500);

    var opts = Tox.Options.create ();
    opts.ipv6_enabled = true;
    opts.udp_enabled = true;

    try {
      this.tox = new Tox.Tox (opts, profile);
    } catch (Tox.ErrNew error) {
      warning ("Tox init failed: %s", error.message);
      this.destroy ();
      var error_dialog = new Gtk.MessageDialog (null,
          Gtk.DialogFlags.MODAL,
          Gtk.MessageType.WARNING,
          Gtk.ButtonsType.OK,
          "Can't load the profile");
      error_dialog.secondary_use_markup = true;
      error_dialog.format_secondary_markup (@"<span color=\"#e74c3c\">$(error.message)</span>");
      error_dialog.response.connect (resp => error_dialog.destroy ()); // if we don't use a signal the profile chooser closes
      error_dialog.show ();
      return;
    }

    //** TEMP DEV ZONE **//
    // HistoryManager history = new HistoryManager ();
    // history.write ("test", "lel");
    //** TEMP DEV ZONE **//

    // Display the settings window while their is no friends online.
    var settings = new SettingsView (this.tox);
    this.chat_stack.add_named (settings, "settings");
    this.chat_stack.set_visible_child (settings);

    var path = avatar_path ();
    if (FileUtils.test (path, FileTest.EXISTS)) {
      tox.send_avatar (path);
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, 48, 48, false);
      this.avatar_image.pixbuf = pixbuf;
    }

    this.init_tray_icon ();
    // TODO
    this.entry_name.set_text (tox.username);
    this.entry_status.set_text (tox.status_message);
    this.image_user_status.set_from_resource ("/chat/tox/ricin/images/status/offline.png");

    // Filter + search.
    this.combobox_friend_filter.append_text ("Online friends");
    this.combobox_friend_filter.append_text ("All friends");
    this.combobox_friend_filter.active = 0;

    /*this.friendlist.set_sort_func ((row1, row2) => {
      var friend1 = row1 as FriendListRow;
      var friend2 = row2 as FriendListRow;
      return friend1.fr.status - friend2.fr.status;
    });*/
    this.friendlist.set_filter_func (row => {
      string? search = this.searchentry_friend.text.down ();
      var friend = row as FriendListRow;
      string name = friend.fr.name.down ();
      Tox.UserStatus status = friend.fr.status;
      var mode = this.combobox_friend_filter.active;

      if (search == null || search.length == 0) {
        if (mode == 0 && status == Tox.UserStatus.OFFLINE) {
          return false;
        }
        return true;
      } else if (mode == 0) {
        if (status == Tox.UserStatus.OFFLINE) {
          return false;
        }
      }

      if (name.index_of (search) != -1) {
        return true;
      }
      return false;
    });

    this.combobox_friend_filter.changed.connect (() => {
      this.friend_list_update_search ();
    });

    this.friendlist.set_sort_func (sort_friendlist_online);
    this.friendlist.bind_model (this.friends, fr => new FriendListRow (fr as Tox.Friend));

    // Add friends from the .tox file.
    uint32[] contacts = this.tox.self_get_friend_list ();
    for (int i = 0; i < contacts.length; i++) {
      uint32 friend_num = contacts[i];
      debug (@"Friend from .tox: num → $friend_num");

      var friend = this.tox.add_friend_by_num (friend_num);
      friend.connected = false;
      friend.position = friends.get_n_items ();
      debug ("Friend position: %u", friend.position);
      debug ("Friend name: %s", friend.get_uname ());
      debug ("Friend status_message: %s", friend.get_ustatus_message ());
      this.friends.append (friend);

      var view_name = "chat-%s".printf (friend.pubkey);
      this.chat_stack.add_named (new ChatView (this.tox, friend, this.chat_stack, view_name), view_name);
    }

    this.entry_status.bind_property ("text", tox, "status_message", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

    tox.notify["connected"].connect ((src, prop) => {
      string icon = "";

      // Sync the status with the one stored on the .tox file.
      switch (this.tox.status) {
        case Tox.UserStatus.ONLINE:
          // Set status to online.
          this.tox.status = Tox.UserStatus.ONLINE;
          icon = "online";
          break;
        case Tox.UserStatus.AWAY:
          // Set status to away.
          this.tox.status = Tox.UserStatus.AWAY;
          icon = "idle";
          break;
        case Tox.UserStatus.BUSY:
          // Set status to busy.
          this.tox.status = Tox.UserStatus.BUSY;
          icon = "busy";
          break;
        default:
          // Set status to offline.
          icon = "offline";
          break;
      }

      icon = this.tox.connected ? icon : "offline";
      this.image_user_status.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
      this.button_user_status.sensitive = this.tox.connected;
    });

    this.tox.friend_request.connect ((id, message) => {
      var dialog = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "Friend request from:");
      dialog.secondary_text = @"$id\n\n$message";
      dialog.add_buttons ("Accept", Gtk.ResponseType.ACCEPT, "Reject", Gtk.ResponseType.REJECT);
      dialog.response.connect (response => {
        if (response == Gtk.ResponseType.ACCEPT) {
          var friend = tox.accept_friend_request (id);
          if (friend != null) {
            this.tox.save_data (); // Needed to avoid breaking profiles if app crash.

            friend.position = friends.get_n_items ();
            debug ("Friend position: %u", friend.position);
            friends.append (friend);
            var view_name = "chat-%s".printf (friend.pubkey);
            chat_stack.add_named (new ChatView (this.tox, friend, this.chat_stack, view_name), view_name);

            var info_message = "The friend request has been accepted. Please wait the contact to appears online.";
            this.notify_message (@"<span color=\"#27ae60\">$info_message</span>", 5000);
          }
        }
        dialog.destroy ();
      });
      dialog.show ();
    });

    this.tox.friend_online.connect ((friend) => {
      if (friend != null) {
        friend.position = friends.get_n_items ();
        debug ("Friend position: %u", friend.position);
        friends.append (friend);
        var view_name = "chat-%s".printf (friend.pubkey);
        chat_stack.add_named (new ChatView (this.tox, friend, this.chat_stack, view_name), view_name);

        // Send our avatar.
        friend.send_avatar ();
      }
    });

    this.notify_message.connect ((message, timeout) =>  {
      this.label_system_notify.use_markup = true;
      this.label_system_notify.set_markup (message);
      this.revealer_system_notify.reveal_child = true;
      Timeout.add (timeout, () => {
        this.revealer_system_notify.reveal_child = false;
        //return Source.REMOVE;
        return false;
      });
    });

    this.tox.run_loop ();
    this.show_all ();
  }

  ~MainWindow () {
    this.tox.save_data ();
  }

  public void show_add_friend_popover_with_text (string toxid = "", string message = "") {
    var friend_message = "";

    if (message.strip () == "") {
      friend_message = "Hello! It's " + this.tox.username + ", let's be friends.";
    }

    this.entry_friend_id.set_text (toxid);
    this.entry_friend_message.buffer.text = friend_message;
    this.button_add_friend_show.visible = false;
    this.button_settings.visible = false;
    this.add_friend.reveal_child = true;
  }

  private void init_tray_icon () {
    try {
      Gdk.Pixbuf tray_icon = new Gdk.Pixbuf.from_resource ("/chat/tox/ricin/images/icons/Ricin-48x48.png");
      this.statusicon_main = new Gtk.StatusIcon.from_pixbuf (tray_icon);
      this.statusicon_main.set_tooltip_text ("Ricin");
      this.statusicon_main.visible = true;
    } catch (Error e) {
      warning ("Pixbuf error: %s", e.message);
    }


    this.menu_statusicon_main = new Gtk.Menu ();

    // ONLINE
    var menuOnline = new Gtk.ImageMenuItem.with_label("Online");
    var menuOnlineImage = new Gtk.Image.from_icon_name("user-available", Gtk.IconSize.MENU);
    menuOnline.always_show_image = true;
    menuOnline.set_image(menuOnlineImage);
    menuOnline.activate.connect (() => {
      this.tox.status = Tox.UserStatus.ONLINE;
      this.image_user_status.icon_name = "user-available";
    });

    // BUSY
    var menuBusy = new Gtk.ImageMenuItem.with_label("Busy");
    var menuBusyImage = new Gtk.Image.from_icon_name("user-busy", Gtk.IconSize.MENU);
    menuBusy.always_show_image = true;
    menuBusy.set_image(menuBusyImage);
    menuBusy.activate.connect (() => {
      this.tox.status = Tox.UserStatus.BUSY;
      this.image_user_status.icon_name = "user-busy";
    });

    // AWAY
    var menuAway = new Gtk.ImageMenuItem.with_label("Away");
    var menuAwayImage = new Gtk.Image.from_icon_name("user-away", Gtk.IconSize.MENU);
    menuAway.always_show_image = true;
    menuAway.set_image(menuAwayImage);
    menuAway.activate.connect (() => {
      this.tox.status = Tox.UserStatus.AWAY;
      this.image_user_status.icon_name = "user-away";
    });

    // QUIT
    var menuQuit = new Gtk.ImageMenuItem.with_label("Quit");
    var menuQuitImage = new Gtk.Image.from_icon_name("window-close", Gtk.IconSize.MENU);
    menuQuit.always_show_image = true;
    menuQuit.set_image(menuQuitImage);
    menuQuit.activate.connect(this.close);

    this.menu_statusicon_main.append (menuOnline);
    this.menu_statusicon_main.append (menuAway);
    this.menu_statusicon_main.append (menuBusy);
    this.menu_statusicon_main.append (menuQuit);

    this.statusicon_main.popup_menu.connect ((button, time) => {
      this.menu_statusicon_main.popup (null, null, null, button, time);
    });

    this.menu_statusicon_main.show_all ();
  }

  [GtkCallback]
  private void show_settings () {
    var settings_view = this.chat_stack.get_child_by_name ("settings");

    if (settings_view != null) {
      this.chat_stack.set_visible_child (settings_view);
    } else {
      var view = new SettingsView (tox);
      this.chat_stack.add_named (view, "settings");
      this.chat_stack.set_visible_child (view);
      this.focused_view = "settings";
    }
  }

  [GtkCallback]
  public void show_add_friend_popover () {
    this.show_add_friend_popover_with_text ();
  }

  [GtkCallback]
  private void hide_add_friend_popover () {
    this.add_friend.reveal_child = false;
    this.label_add_error.set_text ("Add a friend");
    this.button_add_friend_show.visible = true;
    this.button_settings.visible = true;
  }

  [GtkCallback]
  private void ui_add_friend () {
    debug ("add_friend");
    var tox_id = this.entry_friend_id.get_text ();
    var message = this.entry_friend_message.buffer.text;
    var error_message = "";
    this.label_add_error.use_markup = true;
    this.label_add_error.use_markup = true;
    this.label_add_error.halign = Gtk.Align.CENTER;
    this.label_add_error.wrap_mode = Pango.WrapMode.CHAR;
    this.label_add_error.selectable = true;
    this.label_add_error.set_line_wrap (true);

    if (tox_id.length == ToxCore.ADDRESS_SIZE*2) { // bytes -> chars
      try {
        var friend = tox.add_friend (tox_id, message);
        this.tox.save_data (); // Needed to avoid breaking profiles if app crash.
        this.entry_friend_id.set_text (""); // Clear the entry after adding a friend.
        this.add_friend.reveal_child = false;
        this.label_add_error.set_text ("Add a friend");
        this.button_add_friend_show.visible = true;
        return;
      } catch (Tox.ErrFriendAdd error) {
        debug ("Adding friend failed: %s", error.message);
        error_message = error.message;
      }
    } else if (tox_id.index_of ("@") != -1) {
      error_message = "Ricin doesn't supports ToxDNS yet.";
    } else if (tox_id.strip () == "") {
      error_message = "ToxID can't be empty.";
    } else {
      error_message = "ToxID is invalid.";
    }

    if (error_message.strip () != "") {
      this.label_add_error.set_markup (@"<span color=\"#e74c3c\">$error_message</span>");
      return;
    }

    this.add_friend.reveal_child = false;
    this.button_add_friend_show.visible = true;
  }

  [GtkCallback]
  private void show_friend_chatview (Gtk.ListBoxRow row) {
    var item = (row as FriendListRow);
    item.unreadCount = 0;
    item.update_icon ();

    var friend = (row as FriendListRow).fr;
    var view_name = "chat-%s".printf (friend.pubkey);
    var chat_view = this.chat_stack.get_child_by_name (view_name);
    debug ("ChatView name: %s", view_name);

    if (chat_view != null) {
      (chat_view as ChatView).entry.grab_focus ();
      this.chat_stack.set_visible_child (chat_view);
      this.focused_view = view_name;
    }
  }

  [GtkCallback]
  private void set_username_from_entry () {
    this.tox.username = Util.escape_html (this.entry_name.text);
  }

  [GtkCallback]
  private void cycle_user_status () {
    var status = this.tox.status;
    var icon = "";

    switch (status) {
      case Tox.UserStatus.ONLINE:
        // Set status to away.
        this.tox.status = Tox.UserStatus.AWAY;
        icon = "idle";
        //this.image_user_status.icon_name = "user-away";
        break;
      case Tox.UserStatus.AWAY:
        // Set status to busy.
        this.tox.status = Tox.UserStatus.BUSY;
        icon = "busy";
        //this.image_user_status.icon_name = "user-busy";
        break;
      case Tox.UserStatus.BUSY:
        // Set status to online.
        this.tox.status = Tox.UserStatus.ONLINE;
        icon = "online";
        //this.image_user_status.icon_name = "user-available";
        break;
      default:
        icon = "offline";
        //this.image_user_status.icon_name = "user-offline";
        break;
    }

    this.image_user_status.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
  }

  [GtkCallback]
  private void choose_avatar () {
    var chooser = new Gtk.FileChooserDialog ("Select your avatar",
        this,
        Gtk.FileChooserAction.OPEN,
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Open", Gtk.ResponseType.ACCEPT);
    var filter = new Gtk.FileFilter ();
    filter.add_custom (Gtk.FileFilterFlags.MIME_TYPE, info => {
      var mime = info.mime_type;
      return mime.has_prefix ("image/") && mime != "image/gif";
    });
    chooser.filter = filter;
    if (chooser.run () == Gtk.ResponseType.ACCEPT) {
      File avatar = chooser.get_file ();
      this.tox.send_avatar (avatar.get_path ());
      this.avatar_image.pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar.get_path (), 46, 46, true);

      // Copy avatar to ~/.config/tox/avatars/
      try {
        avatar.copy (File.new_for_path (this.avatar_path ()), FileCopyFlags.OVERWRITE);
      } catch (Error err) {
        warning ("Cannot save the avatar in cache: %s", err.message);
      }
    }

    chooser.close ();
  }

  [GtkCallback]
  private void friend_list_update_search () {
    friendlist.invalidate_filter ();
  }
}
