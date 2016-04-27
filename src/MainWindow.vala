[GtkTemplate (ui="/chat/tox/ricin/ui/main-window.ui")]
public class Ricin.MainWindow : Gtk.ApplicationWindow {
  // User profile.
  [GtkChild] Gtk.Box box_profile;
  [GtkChild] Gtk.Image avatar_image;
  //[GtkChild] Gtk.Entry entry_name;
  //[GtkChild] Gtk.Entry entry_status;
  private EditableLabel entry_name;
  private EditableLabel entry_status;
  [GtkChild] Gtk.Button button_user_status;
  [GtkChild] Gtk.Image image_user_status;

  // Search + filter.
  [GtkChild] Gtk.SearchEntry searchentry_friend;
  [GtkChild] Gtk.ComboBoxText combobox_friend_filter;

  // Friend requests.
  [GtkChild] Gtk.Revealer revealer_friend_request;
  [GtkChild] Gtk.Box box_notify_friend_request;
  [GtkChild] Gtk.Box box_friend_request_new;
  [GtkChild] Gtk.Button button_friend_request_expand;
  [GtkChild] Gtk.Image image_friend_request_expand;

  [GtkChild] Gtk.Revealer revealer_friend_request_details;
  [GtkChild] Gtk.Label label_friend_request_pubkey;
  [GtkChild] Gtk.Label label_friend_request_message;
  [GtkChild] Gtk.Button button_friend_request_accept;
  [GtkChild] Gtk.Button button_friend_request_cancel;

  // Friendlist + chatview.
  [GtkChild] public Gtk.ListBox friendlist;
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

  // Bottom buttons.
  [GtkChild] Gtk.Box box_bottom_buttons;
  [GtkChild] Gtk.Button button_settings;

  private SettingsView settings_view;
  private ListStore friends = new ListStore (typeof (Tox.Friend));

  public Tox.Tox tox;
  public string focused_view;
  private Gtk.ListBoxRow selected_row;
  private Gtk.Menu menu_statusicon_main;
  private Gtk.StatusIcon statusicon_main;
  private Settings settings;
  private string window_title;
  private string profile;

  public signal void notify_message (string message, int timeout = 5000);

  public MainWindow (Gtk.Application app, string profile, bool is_new) {
    Object (application: app);
    this.settings = Settings.instance;
    this.profile = profile;

    Gdk.Pixbuf app_icon = new Gdk.Pixbuf.from_resource ("/chat/tox/ricin/images/icons/Ricin-128x128.png");
    string profile_base = File.new_for_path (profile).get_basename ();
    string profile_name = profile_base.replace (".tox", "");

    var app_name = Ricin.APP_NAME;
    this.window_title = @"$app_name - $profile_name";

    this.set_title (window_title);
    // This should fix the #59 issue
    this.set_size_request (960, 500);
    this.set_icon (app_icon);

    var opts = Tox.Options.create ();
    opts.ipv6_enabled = this.settings.network_ipv6;
    opts.udp_enabled = this.settings.network_udp;
    opts.start_port = 33445;
    opts.end_port = 33745;

    if (this.settings.enable_proxy) {
      debug ("Ricin is being proxied.");
      opts.proxy_type = ToxCore.ProxyType.SOCKS5;
      opts.proxy_host = this.settings.proxy_host;
      opts.proxy_port = (uint16) this.settings.proxy_port;
      debug ("Proxy type: SOCKS5");
      debug (@"Proxy host: $(opts.proxy_host)");
      debug (@"Proxy port: $(opts.proxy_port)");
    }

    try {
      this.tox = new Tox.Tox (opts, profile);
    } catch (Tox.ErrNew error) {
      warning ("Tox init failed: %s", error.message);
      this.destroy ();
      var error_dialog = new Gtk.MessageDialog (this,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.WARNING,
        Gtk.ButtonsType.OK,
        "%s", _("Can't load the profile")
      );
      error_dialog.secondary_use_markup = true;
      error_dialog.format_secondary_markup (@"<span color=\"#e74c3c\">$(error.message)</span>");
      error_dialog.response.connect (resp => error_dialog.destroy ()); // if we don't use a signal the profile chooser closes
      error_dialog.show ();
      return;
    }

    // Display the settings view.
    this.settings_view = new SettingsView (this.tox);
    this.chat_stack.add_named (this.settings_view, "settings");
    this.chat_stack.set_visible_child (this.settings_view);
    this.focused_view = "settings";
    this.set_title (this.window_title + " - " + _(@"Settings"));

    this.settings_view.reload_options.connect (this.reload_tox);

    // Display the welcome screen while their is no friends online.
    /*var welcome = new WelcomeView (this.tox);
    this.chat_stack.add_named (welcome, "welcome");
    this.chat_stack.set_visible_child (welcome);
    this.focused_view = "welcome";*/

    var path = avatar_path ();
    if (FileUtils.test (path, FileTest.EXISTS)) {
      tox.send_avatar (path);
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, 48, 48, false);
      this.avatar_image.pixbuf = pixbuf;
    }

    this.init_tray_icon ();
    // TODO
    if (is_new) {
      tox.username = profile_name;
    } else if (tox.username == "") {
      tox.username = "Ricin user";
    }

    if (tox.status_message == "") {
      tox.status_message = "Ricin rocks! https://ricin.im";
    }

    this.entry_name = new EditableLabel.with_bold (tox.username);
    this.entry_status = new EditableLabel (tox.status_message);

    //this.box_profile = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    this.box_profile.pack_start (this.entry_name, true, true, 0);
    this.box_profile.pack_start (this.entry_status, true, true, 0);

    this.entry_status.label.bind_property ("label", tox, "status_message", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
    this.entry_name.label_changed.connect ((text) => {
      debug (@"New username: $text");
      this.tox.username = Util.escape_html (text);
    });
    this.entry_status.label_changed.connect ((text) => {
      debug (@"New status message: $text");
      this.tox.status_message = Util.escape_html (text);
    });

    /*this.entry_name.set_text (tox.username);
    this.entry_status.set_text (tox.status_message);*/
    this.image_user_status.set_from_resource ("/chat/tox/ricin/images/status/offline.png");

    // Filter + search.
    this.combobox_friend_filter.append_text (_("Online friends"));
    this.combobox_friend_filter.append_text (_("All friends"));
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
        if (friend.unreadCount > 0) {
          return true;
        }

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

    this.combobox_friend_filter.changed.connect (this.friend_list_update_search);

    this.friendlist.set_sort_func (sort_friendlist_online);
    this.friendlist.bind_model (this.friends, fr => new FriendListRow (fr as Tox.Friend));

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
      debug (@"Received friend request from $id: $message");

      this.revealer_friend_request.reveal_child = true;
      this.revealer_friend_request_details.reveal_child = false;

      this.label_friend_request_pubkey.set_text (id);
      this.label_friend_request_message.set_text (message);
      this.image_friend_request_expand.icon_name = "go-down-symbolic";

      this.button_friend_request_expand.clicked.connect (() => {
        bool is_expanded = this.revealer_friend_request_details.child_revealed;
        this.revealer_friend_request_details.reveal_child = !is_expanded;
        this.image_friend_request_expand.icon_name = (is_expanded) ? "go-top-symbolic" : "go-down-symbolic";
      });

      this.button_friend_request_accept.clicked.connect (() => {
        debug (@"Accepted friend request from $id");
        var friend = tox.accept_friend_request (id);
        if (friend != null) {
          friend.name = id; // To avoid blank items.
          this.tox.save_data (); // Needed to avoid breaking profiles if app crash.

          friend.position = friends.get_n_items ();
          debug ("Friend position: %u", friend.position);
          friends.append (friend);
          var view_name = "chat-%s".printf (friend.pubkey);
          chat_stack.add_named (new ChatView (this.tox, friend, this.chat_stack, view_name), view_name);
        }

        this.revealer_friend_request.reveal_child = false;
        this.revealer_friend_request_details.reveal_child = false;
        this.label_friend_request_pubkey.set_text ("");
        this.label_friend_request_message.set_text ("");
        /*this.box_notify_friend_request.visible = false;
        this.box_friend_request_new.visible = false;
        this.image_friend_request_expand.icon_name = "go-down-symbolic";*/
      });

      this.button_friend_request_cancel.clicked.connect (() => {
        debug (@"Rejected friend request from $id");
        this.revealer_friend_request.reveal_child = false;
        this.revealer_friend_request_details.reveal_child = false;
        this.label_friend_request_pubkey.set_text ("");
        this.label_friend_request_message.set_text ("");
        /*this.box_notify_friend_request.visible = false;
        this.box_friend_request_new.visible = false;
        this.image_friend_request_expand.icon_name = "go-down-symbolic";*/
      });
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
    this.append_friends.begin ();
  }

  private async void append_friends () {
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
  }

  private string avatar_path () {
    return Tox.profile_dir () + "avatars/" + this.tox.pubkey + ".png";
  }

  /**
  * This is the sort method used for sorting contacts based on:
  * Contact have unreadCount > 0: top.
  * Contact is online (top) → Contact is offline (end)
  * Contact status: Online → Away → Busy → Blocked → Offlines with name → Offlines without name.
  */
  public static int sort_friendlist_online (Gtk.Widget row1, Gtk.Widget row2) {
    var friend1 = (row1 as FriendListRow);
    var friend2 = (row2 as FriendListRow);

    if (friend1.unreadCount > friend2.unreadCount) {
      return -1;
    }

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
    var dialog = new Gtk.MessageDialog (
      this,
      Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
      "Are you sure you want to delete \"%s\"?", name
    );
    dialog.secondary_text = @"This will remove \"$name\" and the chat history with it forever.";
    dialog.add_buttons (_("Yes"), Gtk.ResponseType.ACCEPT, _("No"), Gtk.ResponseType.REJECT);
    dialog.response.connect (response => {
      if (response == Gtk.ResponseType.ACCEPT) {
        bool result = friend.delete ();
        if (result) {
          if (friend.position == 0) {
            this.friends.remove (0); // TODO: Verify this.
          } else {
            this.friends.remove (friend.position);
          }
          this.friendlist.invalidate_filter (); // Update the friendlist.
          this.friendlist.invalidate_sort (); // Update the friendlist.
          this.tox.save_data ();
        }
      }

      dialog.destroy ();
    });

    dialog.show ();
  }

  public void show_add_friend_popover_with_text (string toxid = "", string message = "") {
    var friend_message = "";

    if (message.strip () == "") {
      var username = this.tox.username;
      friend_message = _("Hello! It's %s, let's be friends.").printf (username);
    }

    this.entry_friend_id.set_text (toxid);
    this.entry_friend_message.buffer.text = friend_message;
    //this.button_add_friend_show.visible = false;
    //this.button_settings.visible = false;
    this.box_bottom_buttons.visible = false;
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
    var menuOnline = new Gtk.ImageMenuItem.with_label(_("Online"));
    var menuOnlineImage = new Gtk.Image.from_resource("/chat/tox/ricin/images/status/online.png");
    menuOnline.always_show_image = true;
    menuOnline.set_image(menuOnlineImage);
    menuOnline.activate.connect (() => {
      this.tox.status = Tox.UserStatus.ONLINE;
      this.image_user_status.set_from_resource("/chat/tox/ricin/images/status/online.png");
    });

    // BUSY
    var menuBusy = new Gtk.ImageMenuItem.with_label(_("Busy"));
    var menuBusyImage = new Gtk.Image.from_resource("/chat/tox/ricin/images/status/busy.png");
    menuBusy.always_show_image = true;
    menuBusy.set_image(menuBusyImage);
    menuBusy.activate.connect (() => {
      this.tox.status = Tox.UserStatus.BUSY;
      this.image_user_status.set_from_resource("/chat/tox/ricin/images/status/busy.png");
    });

    // AWAY
    var menuAway = new Gtk.ImageMenuItem.with_label(_("Away"));
    var menuAwayImage = new Gtk.Image.from_resource("/chat/tox/ricin/images/status/idle.png");
    menuAway.always_show_image = true;
    menuAway.set_image(menuAwayImage);
    menuAway.activate.connect (() => {
      this.tox.status = Tox.UserStatus.AWAY;
      this.image_user_status.set_from_resource("/chat/tox/ricin/images/status/idle.png");
    });

    // QUIT
    var menuQuit = new Gtk.ImageMenuItem.with_label(_("Quit"));
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

    this.statusicon_main.activate.connect(() => {
      if (this.visible) {
        this.hide ();
      } else {
        this.show ();
      }
    });

    this.menu_statusicon_main.show_all ();
  }

  public void display_settings () {
    this.friendlist.unselect_row (this.selected_row);
    var settings_view = this.chat_stack.get_child_by_name ("settings");

    if (settings_view != null) {
      this.chat_stack.set_visible_child (settings_view);
      this.focused_view = "settings";
    } else {
      var view = new SettingsView (tox);
      this.chat_stack.add_named (view, "settings");
      this.chat_stack.set_visible_child (view);
      this.focused_view = "settings";
    }
  }

  private void reload_tox () {
    /**
    * TODO + FIXME
    **/
    /**
    var opts = Tox.Options.create ();
    opts.ipv6_enabled = this.settings.get_bool ("ricin.network.ipv6");
    opts.udp_enabled = this.settings.get_bool ("ricin.network.udp");

    if (this.settings.get_bool ("ricin.network.proxy.enabled")) {
      opts.proxy_type = ToxCore.ProxyType.SOCKS5;
      opts.proxy_host = this.settings.get_string ("ricin.network.proxy.ip_address");
      opts.proxy_port = (uint16) this.settings.get_int ("ricin.network.proxy.port");
    }

    try {
      this.tox = new Tox.Tox (opts, this.profile);
    } catch (Error e) {
      error (@"Cannot reload profile.");
    }
    **/

    /**
    * Until I find a fix for the code above, lets just warn the user that
    * a restart is needed to have new network settings working.
    **/
    var dialog = new Gtk.MessageDialog (
      this,
      Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
      "%s", _("Restart required")
    );
    dialog.secondary_text = _("Ricin needs to restart in order to apply settings. Do you want to restart?");
    dialog.add_buttons (_("Restart now"), Gtk.ResponseType.ACCEPT, _("Restart later"), Gtk.ResponseType.REJECT);
    dialog.response.connect (response => {
      if (response == Gtk.ResponseType.ACCEPT) {
        this.close ();
        //Gtk.main_quit ();
      }
      dialog.destroy ();
    });

    dialog.show ();
  }

  [GtkCallback]
  private void show_settings () {
    this.display_settings ();
    this.set_title (this.window_title + " - " + _("Settings"));
  }

  [GtkCallback]
  public void show_add_friend_popover () {
    this.show_add_friend_popover_with_text ();
  }

  [GtkCallback]
  private void hide_add_friend_popover () {
    this.add_friend.reveal_child = false;
    this.label_add_error.set_text (_("Add a friend"));
    //this.button_add_friend_show.visible = true;
    //this.button_settings.visible = true;
    this.box_bottom_buttons.visible = true;
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

    if (tox_id.length == ToxCore.ADDRESS_SIZE * 2) { // bytes -> chars
      try {
        var friend = tox.add_friend (tox_id, message);
        this.tox.save_data (); // Needed to avoid breaking profiles if app crash.
        this.entry_friend_id.set_text (""); // Clear the entry after adding a friend.
        this.add_friend.reveal_child = false;
        this.label_add_error.set_text (_("Add a friend"));
        //this.button_add_friend_show.visible = true;
        this.box_bottom_buttons.visible = true;
        return;
      } catch (Tox.ErrFriendAdd error) {
        debug ("Adding friend failed: %s", error.message);
        error_message = error.message;
      }
    } else if (tox_id.index_of ("@") != -1) {
      error_message = _("Ricin doesn't supports ToxDNS yet.");
    } else if (tox_id.strip () == "") {
      error_message = _("ToxID can't be empty.");
    } else {
      error_message = _("ToxID is invalid.");
    }

    if (error_message.strip () != "") {
      this.label_add_error.set_markup (@"<span color=\"#e74c3c\">$error_message</span>");
      return;
    }

    this.add_friend.reveal_child = false;
    //this.button_add_friend_show.visible = true;
    this.box_bottom_buttons.visible = true;
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
      this.selected_row = row;
      this.set_title (@"$(this.window_title) - $(friend.get_uname ())");
    }
  }

  //[GtkCallback]
  /*private void set_username_from_entry () {
    this.tox.username = Util.escape_html (this.entry_name.label.text);
  }*/

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
    var chooser = new Gtk.FileChooserDialog (_("Select your avatar"),
        this,
        Gtk.FileChooserAction.OPEN,
        _("_Cancel"), Gtk.ResponseType.CANCEL,
        _("_Open"), Gtk.ResponseType.ACCEPT);
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

  ~MainWindow () {
    this.tox.save_data ();
    this.settings.save_settings ();
    this.tox.disconnect ();
    //this.tox.handle = null;
    //this.tox = null;
  }
}
