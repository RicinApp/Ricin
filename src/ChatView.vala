[GtkTemplate (ui="/chat/tox/ricin/ui/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
  [GtkChild] Gtk.Image user_avatar;
  [GtkChild] Gtk.Label username;
  [GtkChild] Gtk.Label status_message;
  [GtkChild] Gtk.ScrolledWindow scroll_messages;
  [GtkChild] Gtk.ListBox messages_list;
  [GtkChild] public Gtk.Entry entry;
  [GtkChild] Gtk.Button send;
  [GtkChild] Gtk.Button send_file;
  [GtkChild] Gtk.Button button_audio_call;
  [GtkChild] Gtk.Button button_video_call;

  /* Emoticons popover */
  [GtkChild] Gtk.Box box_popover_emoticons;
  [GtkChild] Gtk.Button button_show_emoticons;
  Gtk.Popover popover_emoticons;

  /* Friend's typing */
  [GtkChild] Gtk.Revealer friend_typing;
  [GtkChild] Gtk.Label label_friend_is_typing;

  /* Unread messages (scroll to bottom) */
  [GtkChild] Gtk.Revealer revealer_unread_messages;

  /* Friend menu toggle */
  [GtkChild] Gtk.Button button_toggle_friend_menu;
  [GtkChild] Gtk.Revealer revealer_friend_menu;

  /* Friend menu sidebar */
  [GtkChild] Gtk.Image friend_profil_avatar;
  [GtkChild] Gtk.Image image_friend_status;
  [GtkChild] Gtk.Label label_friend_profil_name;
  [GtkChild] Gtk.Label label_friend_profile_status_message;
  [GtkChild] Gtk.Label label_friend_last_seen;
  [GtkChild] Gtk.Button button_friend_copy_toxid;
  [GtkChild] Gtk.Button button_friend_block;
  [GtkChild] Gtk.Button button_friend_delete;

  /* ChatView notify system UI */
  [GtkChild] Gtk.Revealer notify;
  [GtkChild] Gtk.Image image_notify;
  [GtkChild] Gtk.Label label_notify_text;
  [GtkChild] Gtk.Button button_notify_close;

  public Tox.Friend fr;
  private weak Tox.Tox handle;
  private weak Gtk.Stack stack;
  private string view_name;
  private HistoryManager history;
  private SettingsManager settings;

  private Tox.UserStatus last_status;
  private string last_message_sender;
  private string last_message;
  private bool is_bottom = true;

  /**
  * TODO: Use this enum to determine the current message type.
  **/
  private enum MessageRowType {
    Normal,
    Action,
    System,
    InlineImage,
    InlineFile,
    GtkListBoxRow
  }

  private string time () {
    return new DateTime.now_local ().format ("%H:%M:%S %p");
  }

  public ChatView (Tox.Tox handle, Tox.Friend fr, Gtk.Stack stack, string view_name) {
    this.handle = handle;
    this.fr = fr;
    this.stack = stack;
    this.view_name = view_name;
    this.history = new HistoryManager (this.fr.pubkey);
    this.settings = SettingsManager.instance;

    if (this.fr.name == null) {
      this.label_friend_profil_name.set_text (this.fr.get_uname ());
      this.label_friend_profile_status_message.set_text (this.fr.get_ustatus_message ());

      this.username.set_text (this.fr.get_uname ());
      this.status_message.set_markup (Util.render_litemd (this.fr.get_ustatus_message ()));
    } else {
      this.label_friend_profil_name.set_text (this.fr.name);
      this.label_friend_profile_status_message.set_markup (Util.render_litemd (this.fr.status_message));

      this.username.set_text (this.fr.name);
      this.status_message.set_markup (Util.render_litemd (this.fr.status_message));
    }

    this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

    debug (@"Status message for $(fr.name): $(fr.status_message)");
    //this.status_message.set_text (fr.status_message);
    fr.bind_property ("status-message", status_message, "label", BindingFlags.DEFAULT);
    fr.bind_property ("name", this.label_friend_profil_name, "label", BindingFlags.DEFAULT);
    fr.bind_property ("status-message", this.label_friend_profile_status_message, "label", BindingFlags.DEFAULT);
    //this.status_message.set_markup (Util.add_markup (fr.status_message));

    var _avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
    if (FileUtils.test (_avatar_path, FileTest.EXISTS)) {
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (_avatar_path, 48, 48, false);
      this.user_avatar.pixbuf = pixbuf;
      this.friend_profil_avatar.pixbuf = pixbuf;
    }

    this.entry.key_press_event.connect ((event) => {
      if (event.keyval == Gdk.Key.Up && this.entry.get_text () == "") {
        this.entry.set_text (this.last_message);
        this.entry.set_position (-1);
        return true;
      } else if (event.keyval == Gdk.Key.Down && this.entry.get_text () == this.last_message) {
        this.entry.set_text ("");
      }
      return false;
    });


    this.popover_emoticons = new Gtk.Popover (this.button_show_emoticons);
    //set popover content
    this.popover_emoticons.set_size_request (250, 150);
    this.popover_emoticons.set_position (Gtk.PositionType.TOP | Gtk.PositionType.LEFT);
    this.popover_emoticons.set_modal (false);
    this.popover_emoticons.set_transitions_enabled (true);
    this.popover_emoticons.add (this.box_popover_emoticons);

    this.popover_emoticons.closed.connect (() => {
      this.entry.grab_focus_without_selecting ();
    });

    this.button_show_emoticons.clicked.connect (() => {
      if (this.popover_emoticons.visible == false) {
        this.popover_emoticons.show_all ();
      } else {
        this.popover_emoticons.hide ();
      }

      // Avoid the user to loose focus with chat entry.
      this.entry.grab_focus_without_selecting ();
    });

    fr.friend_info.connect ((message) => {
      this.last_message_sender = "friend";
      messages_list.add (new SystemMessageListRow (message));

      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
      //this.add_row (MessageRowType.System, new SystemMessageListRow (message));
    });

    handle.global_info.connect ((message) => {
      this.last_message_sender = "friend";
      messages_list.add (new SystemMessageListRow (message));
      //this.add_row (MessageRowType.System, new SystemMessageListRow (message));
    });

    fr.avatar.connect (p => {
      this.user_avatar.pixbuf = p;
      this.friend_profil_avatar.pixbuf = p;

      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
    });

    fr.message.connect (message => {
      var current_time = time ();
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

      var visible_child = this.stack.get_visible_child_name ();
      var main_window = this.get_toplevel () as MainWindow;

      if (!main_window.is_active) {
        var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
        if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 46, 46, true);
          Notification.notify (this.fr.name, message, 5000, pixbuf);
        } else {
          Notification.notify (this.fr.name, message, 5000);
        }
      }

      var is_child = (this.last_message_sender == "friend");
      if (message.index_of (">", 0) == 0) {
        var markup = Util.add_markup (message);
        this.last_message_sender = "friend";
        messages_list.add (new QuoteMessageListRow (this.handle, this.fr, markup, current_time, -1, is_child));
      } else {
        this.history.write (this.fr.pubkey, @"[$current_time] [$(this.fr.name)] $message");
        this.last_message_sender = "friend";
        messages_list.add (new MessageListRow (this.handle, this.fr, Util.add_markup (message), current_time, -1, is_child));
      }
      //this.add_row (MessageRowType.Normal, new MessageListRow (fr.name, Util.add_markup (message), time ()));
    });

    fr.action.connect (message => {
      var current_time = time ();
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

      var visible_child = this.stack.get_visible_child_name ();
      if (visible_child != this.view_name) {

        var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
        if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 46, 46, true);
          Notification.notify (fr.name, message, 5000, pixbuf);
        } else {
          Notification.notify (fr.name, message, 5000);
        }

      }

      this.history.write (this.fr.pubkey, @"[$current_time] ** $(this.fr.name) $message");

      string message_escaped = @"<b>$(Util.escape_html(fr.name))</b> $(Util.escape_html(message))";
      this.last_message_sender = "friend";
      messages_list.add (new SystemMessageListRow (message_escaped));
      //this.add_row (MessageRowType.Action, new SystemMessageListRow (message_escaped));
    });

    fr.file_transfer.connect ((name, size, id) => {
      var current_time = time ();
      string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
      string filename = name;
      int i = 0;

      while (FileUtils.test (downloads + filename, FileTest.EXISTS)) {
        filename = @"$(++i)-$name";
      }

      this.history.write (this.fr.pubkey, @"[$current_time] ** $(this.fr.name) sent you a file: $filename");

      //FileUtils.set_data (path, bytes.get_data ());
      var path = @"/tmp/$filename";
      var file_path = File.new_for_path (path);
      var file_content_type = ContentType.guess (path, null, null);

      /**
      * TODO: debug this.
      **/
      /*if (file_content_type.has_prefix ("image/")) {
        var image_row = new InlineImageMessageListRow (this.handle, fr, id, fr.name, path, time (), false);
        image_row.accept_image.connect ((response, file_id) => {
          fr.reply_file_transfer (response, file_id);
        });
        messages_list.add (image_row);
      } else {*/
      this.last_message_sender = "friend";
      var file_row = new InlineFileMessageListRow (this.handle, fr, id, fr.name, path, size, time ());
      file_row.accept_file.connect ((response, file_id) => {
        fr.reply_file_transfer (response, file_id);
      });
      messages_list.add (file_row);
      //}
    });

    fr.bind_property ("connected", entry, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send_file, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", button_show_emoticons, "sensitive", BindingFlags.DEFAULT);
    //fr.bind_property ("typing", friend_typing, "reveal_child", BindingFlags.DEFAULT);
    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);

    this.entry.changed.connect (() => {
      bool send_typing_notification = this.settings.get_bool ("ricin.interface.send_typing_notification");
      if (!send_typing_notification) {
        return;
      }
      var is_typing = (this.entry.text.strip () != "");
      this.fr.send_typing (is_typing);
    });
    this.entry.backspace.connect (() => {
      bool send_typing_notification = this.settings.get_bool ("ricin.interface.send_typing_notification");
      if (!send_typing_notification) {
        return;
      }
      var is_typing = (this.entry.text.strip () != "");
      this.fr.send_typing (is_typing);
    });

    this.fr.notify["typing"].connect ((obj, prop) => {
      string friend_name = Util.escape_html (this.fr.name);
      this.label_friend_is_typing.set_markup (@"<i>$friend_name " + _("is typing") + "</i>");
      this.friend_typing.reveal_child = this.fr.typing;
    });

    this.fr.notify["status-message"].connect ((obj, prop) => {
      string markup = Util.add_markup (this.fr.status_message);
      debug (@"Markup for md: $markup");
      this.status_message.set_markup (markup);
      this.label_friend_profile_status_message.set_markup (markup);

      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
    });

    this.fr.notify["status"].connect ((obj, prop) => {
      var status = this.fr.status;
      var icon = "";

      switch (status) {
        case Tox.UserStatus.ONLINE:
          icon = "online";
          //messages_list.add(new SystemMessageListRow(fr.name + " is now online"));
          break;
        case Tox.UserStatus.AWAY:
          icon = "idle";
          //messages_list.add(new SystemMessageListRow(fr.name + " is now away"));
          break;
        case Tox.UserStatus.BUSY:
          icon = "busy";
          //messages_list.add(new SystemMessageListRow(fr.name + " is now busy"));
          break;
        default:
          icon = "offline";
          //messages_list.add(new SystemMessageListRow(fr.name + " is now offline"));
          break;
      }

      this.image_friend_status.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

      bool display_friends_status_changes = this.settings.get_bool ("ricin.interface.display_friends_status_changes");
      if (this.last_status != status && display_friends_status_changes) {
        var status_str = Util.status_to_string (this.fr.status);
        this.last_message_sender = "friend";
        messages_list.add (new StatusMessageListRow (fr.name + _(" is now ") + status_str, status));
        this.last_status = status;
      }
    });
  }

  public void show_notice (string text, string icon_name = "help-info-symbolic") {
    this.image_notify.icon_name = icon_name;
    this.label_notify_text.set_text (text);
    this.button_notify_close.clicked.connect (() => {
      this.notify.reveal_child = false;
    });

    this.notify.reveal_child = true;
    this.scroll_to_bottom ();
  }

  [GtkCallback]
  private void toggle_friend_menu () {
    this.revealer_friend_menu.set_reveal_child (!this.revealer_friend_menu.child_revealed);
    this.entry.grab_focus_without_selecting ();
  }

  [GtkCallback]
  private void delete_friend () {
    var main_window = this.get_toplevel () as MainWindow;
    main_window.remove_friend (this.fr);
  }

  [GtkCallback]
  private void block_friend () {
    this.fr.blocked = !this.fr.blocked;
    if (this.fr.blocked) {
      this.button_friend_block.label = _("Unblock");
    } else {
      this.button_friend_block.label = _("Block");
    }
  }

  [GtkCallback]
  private void copy_friend_toxid () {
    Gtk.Clipboard
    .get (Gdk.SELECTION_CLIPBOARD)
    .set_text (this.fr.pubkey, -1);
  }

  [GtkCallback]
  private void send_message () {
    var current_time = time ();
    var user = this.handle.username;
    string markup;

    var message = this.entry.get_text ();
    this.last_message = message;
    if (message.strip () == "") {
      return;
    }
    // Notice example:
    /*else if (message.index_of ("/n", 0) == 0) {
      var msg = message.replace ("/n ", "");
      return;
      this.show_notice(msg);
    }*/

    var is_child = (this.last_message_sender == "ricin");
    if (message.has_prefix ("/me ")) {

      var action = message.substring (4);
      debug (@"action=$action");
      var escaped = Util.escape_html (action);
      debug (@"escaped=$escaped\nuser=$user");
      markup = @"<b>$user</b> $escaped";

      this.history.write (this.fr.pubkey, @"[$current_time] ** $(this.handle.username) $action");
      messages_list.add (new SystemMessageListRow (markup));
      fr.send_action (action);
    } else if (message.index_of (">", 0) == 0) {
      markup = Util.add_markup (message);
      uint32 message_id = fr.send_message (message);
      messages_list.add (new QuoteMessageListRow (this.handle, null, markup, time (), message_id, is_child));
    } else {
      markup = Util.add_markup (message);

      this.history.write (this.fr.pubkey, @"[$current_time] [$(this.handle.username)] $message");
      uint32 message_id = fr.send_message (message);
      messages_list.add (new MessageListRow (this.handle, null, markup, time (), message_id, is_child));
    }

    // clear the entry
    this.entry.text = "";
    this.last_message_sender = "ricin";
  }

  [GtkCallback]
  private void choose_file_to_send () {
    var chooser = new Gtk.FileChooserDialog (_("Choose a file"), null, Gtk.FileChooserAction.OPEN,
        _("_Cancel"), Gtk.ResponseType.CANCEL,
        _("_Open"), Gtk.ResponseType.ACCEPT);
    if (chooser.run () == Gtk.ResponseType.ACCEPT) {
      var current_time = time ();
      var filename = chooser.get_filename ();

      File file = File.new_for_path (filename);
      FileInfo info = file.query_info ("standard::*", 0);
      var file_id = fr.send_file (filename);
      var file_content_type = ContentType.guess (filename, null, null);
      var size = info.get_size ();

      var fname = file.get_basename ();
      this.history.write (this.fr.pubkey, @"[$current_time] ** You sent a file to $(this.fr.name): $fname");

      if (file_content_type.has_prefix ("image/")) {
        /*var pixbuf = new Gdk.Pixbuf.from_file_at_scale (filename, 400, 250, true);*/
        var image_widget = new InlineImageMessageListRow (this.handle, fr, file_id, this.handle.username, file.get_path (), time (), true);
        image_widget.button_save_inline.visible = false;
        messages_list.add (image_widget);
      } else {
        //fr.friend_info (@"Sending file $filename");
        var file_row = new InlineFileMessageListRow (this.handle, fr, file_id, this.handle.username, filename, size, time ());
        messages_list.add (file_row);
      }
    }
    chooser.close ();
  }

  // Last scroll pos.
  private double _bottom_scroll = 0.0;
  private bool force_scroll = false;

  [GtkCallback]
  private void scroll_to_bottom () {
    /**
    * Check if the scrollbar is at the very max scroll, else don't do autoscroll.
    * This prevent users searching in the history but getting bottom'd by the autoscroll.
    **/
    Gtk.Adjustment adj = this.scroll_messages.get_vadjustment ();
    if (adj.value == this._bottom_scroll) {
      adj.set_value (adj.get_upper () - adj.get_page_size ());
      this.is_bottom = true;
      this.revealer_unread_messages.reveal_child = false;
    } else {
      this.is_bottom = false;
      this.revealer_unread_messages.reveal_child = true;
    }

    this._bottom_scroll = adj.get_upper () - adj.get_page_size ();
  }

  [GtkCallback]
  private void unread_messages_scroll () {
    this.revealer_unread_messages.notify["child-revealed"].connect (() => {
      if (this.revealer_unread_messages.reveal_child == false) {
        this.scroll_bottom ();
        this.entry.grab_focus_without_selecting ();
      }
    });
    this.revealer_unread_messages.reveal_child = false;
  }

  private void scroll_bottom () {
    Gtk.Adjustment adj = this.scroll_messages.get_vadjustment ();
    adj.set_value (adj.get_upper () - adj.get_page_size ());
    this._bottom_scroll = adj.get_upper () - adj.get_page_size ();
    this.is_bottom = true;
  }
  private void toggle_unread_notice () {
    this.revealer_unread_messages.reveal_child = !!this.is_bottom;
  }
}
