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
  [GtkChild] Gtk.Revealer friend_typing;

  /* Friend menu toggle */
  [GtkChild] Gtk.Button button_toggle_friend_menu;
  [GtkChild] Gtk.Revealer revealer_friend_menu;

  [GtkChild] Gtk.Image friend_profil_avatar;
  [GtkChild] Gtk.Image image_friend_status;
  [GtkChild] Gtk.Label label_friend_profil_name;
  [GtkChild] Gtk.Label label_friend_profile_status_message;
  [GtkChild] Gtk.Label label_friend_last_seen;
  [GtkChild] Gtk.Button button_friend_copy_toxid;
  [GtkChild] Gtk.Button button_friend_block;
  [GtkChild] Gtk.Button button_friend_delete;

  public Tox.Friend fr;
  private weak Tox.Tox handle;
  private weak Gtk.Stack stack;
  private string view_name;

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

    if (this.fr.name == null) {
      this.label_friend_profil_name.set_text (this.fr.pubkey);
      this.label_friend_profile_status_message.set_text ("");

      this.username.set_text (this.fr.pubkey);
      this.status_message.set_markup (this.fr.last_online ("<b>Last online:</b> %H:%M %d/%m/%Y"));
    } else {
      this.label_friend_profil_name.set_text (this.fr.name);
      this.label_friend_profile_status_message.set_markup (Util.render_litemd(this.fr.status_message));

      this.username.set_text (this.fr.name);
      this.status_message.set_markup (Util.render_litemd(this.fr.status_message));
    }

    this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

    debug (@"Status message for $(fr.name): $(fr.status_message)");
    this.status_message.set_text (fr.status_message);
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

    fr.friend_info.connect ((message) => {
      messages_list.add (new SystemMessageListRow (message));

      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
      //this.add_row (MessageRowType.System, new SystemMessageListRow (message));
    });

    handle.global_info.connect ((message) => {
      messages_list.add (new SystemMessageListRow (message));
      //this.add_row (MessageRowType.System, new SystemMessageListRow (message));
    });

    fr.avatar.connect (p => {
      this.user_avatar.pixbuf = p;
      this.friend_profil_avatar.pixbuf = p;

      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
    });

    fr.message.connect (message => {
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

      var visible_child = this.stack.get_visible_child_name ();
      var main_window = this.get_toplevel () as MainWindow;

      if (!main_window.is_active) {
        var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
        if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 46, 46, true);
          Notification.notify (fr.name, message, 5000, pixbuf);
        } else {
          Notification.notify (fr.name, message, 5000);
        }
      }

      messages_list.add (new MessageListRow (this.handle, fr.name, Util.add_markup (message), time ()));
      //this.add_row (MessageRowType.Normal, new MessageListRow (fr.name, Util.add_markup (message), time ()));
    });

    fr.action.connect (message => {
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

      string message_escaped = @"<b>$(Util.escape_html(fr.name))</b> $(Util.escape_html(message))";
      messages_list.add (new SystemMessageListRow (message_escaped));
      //this.add_row (MessageRowType.Action, new SystemMessageListRow (message_escaped));
    });

    fr.file_transfer.connect ((name, size, id) => {
      string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
      string filename = name;
      int i = 0;

      while (FileUtils.test (downloads + filename, FileTest.EXISTS))
        filename = @"$(++i)-$name";

      //FileUtils.set_data (path, bytes.get_data ());
      var path = @"/tmp/$name";
      var file_content_type = ContentType.guess (path, null, null);

      if (file_content_type.has_prefix ("image/")) {
        var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, 400, 250, true);
        messages_list.add (new InlineImageMessageListRow (this.handle, fr.name, path, pixbuf, time ()));
        //return;
      } else {
        var file_row = new InlineFileMessageListRow (this.handle, fr, id, fr.name, path, size, time ());
        file_row.accept_file.connect ((response, file_id) => {
          fr.reply_file_transfer (response, file_id);
        });
        messages_list.add (file_row);
      }
    });

    /*fr.file_done.connect ((name, bytes) => {
      string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
      string filename = name;
      int i = 0;
      while (FileUtils.test (downloads + filename, FileTest.EXISTS)) {
        filename = @"$(++i)-$name";
      }

      var path = @"/tmp/$filename";
      FileUtils.set_data (path, bytes.get_data ());
      var file_content_type = ContentType.guess (path, null, null);
      if (file_content_type.has_prefix ("image/")) {
        var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, 400, 250, true);
        messages_list.add (new InlineImageMessageListRow (fr.name, path, pixbuf, time ()));
      }
    });*/

    fr.bind_property ("connected", entry, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send_file, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("typing", friend_typing, "reveal_child", BindingFlags.DEFAULT);
    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);

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
          break;
        case Tox.UserStatus.AWAY:
          icon = "idle";
          break;
        case Tox.UserStatus.BUSY:
          icon = "busy";
          break;
        default:
          icon = "offline";
          break;
      }

      this.image_friend_status.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
    });
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
      this.button_friend_block.label = "Unblock";
    } else {
      this.button_friend_block.label = "Block";
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
    var user = this.handle.username;
    string markup;

    var message = this.entry.get_text ();
    if (message.strip () == "") {
      return;
    }

    if (message.has_prefix ("/me ")) {
      var action = message.substring (4);
      debug (@"action=$action");
      var escaped = Util.escape_html (action);
      debug (@"escaped=$escaped\nuser=$user");
      markup = @"<b>$user</b> $escaped";
      messages_list.add (new SystemMessageListRow (markup));
      fr.send_action (action);
    } else {
      markup = Util.add_markup (message);
      messages_list.add (new MessageListRow (this.handle, user, markup, time ()));
      fr.send_message (message);
    }

    // clear the entry
    this.entry.text = "";
  }

  /*private bool handle_links (string uri) {
    if (!uri.has_prefix ("tox:")) {
      return false; // Default behavior.
    }

    var main_window = this.get_toplevel () as MainWindow;
    var toxid = uri.split ("tox:")[1];
    if (toxid.length == ToxCore.ADDRESS_SIZE * 2) {
      main_window.show_add_friend_popover_with_text (toxid);
    } else {
      var info_message = "ToxDNS is not supported yet.";
      main_window.notify_message (@"<span color=\"#e74c3c\">$info_message</span>");
    }

    return true;
  }*/

  [GtkCallback]
  private void choose_file_to_send () {
    var chooser = new Gtk.FileChooserDialog ("Choose a File", null, Gtk.FileChooserAction.OPEN,
        "_Cancel", Gtk.ResponseType.CANCEL,
        "_Open", Gtk.ResponseType.ACCEPT);
    if (chooser.run () == Gtk.ResponseType.ACCEPT) {
      var filename = chooser.get_filename ();
      File file = File.new_for_path (filename);
      FileInfo info = file.query_info ("standard::*", 0);
      var file_id = fr.send_file (filename);
      var file_content_type = ContentType.guess (filename, null, null);
      var size = info.get_size ();

      if (file_content_type.has_prefix ("image/")) {
        var pixbuf = new Gdk.Pixbuf.from_file_at_scale (filename, 400, 250, true);
        var image_widget = new InlineImageMessageListRow (this.handle, this.handle.username, filename, pixbuf, time ());
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

  [GtkCallback]
  private void scroll_to_bottom () {
    var adjustment = this.scroll_messages.get_vadjustment ();
    adjustment.set_value (adjustment.get_upper () - adjustment.get_page_size ());
  }

  /*private void add_row (MessageRowType type, IMessageListRow row) {
    switch (type) {
      case MessageRowType.Normal:
        debug ("Appending a Normal MessageRow");
        this.messages_list.add (row);
        row.position = this.messages_list.get_n_items ();
        break;
      case MessageRowType.Action:
        debug ("Appending an Action MessageRow");
        this.messages_list.add (row);
        row.position = this.messages_list.get_n_items ();
        break;
      case MessageRowType.System:
        debug ("Appending a System MessageRow");
        this.messages_list.add (row);
        row.position = this.messages_list.get_n_items ();
        break;
      case MessageRowType.InlineImage:
        debug ("Appending an InlineImage MessageRow");
        this.messages_list.add (row);
        row.position = this.messages_list.get_n_items ();
        break;
      case MessageRowType.InlineFile:
        debug ("Appending an InlineFile MessageRow");
        this.messages_list.add (row);
        row.position = this.messages_list.get_n_items ();
        break;
      case MessageRowType.GtkListBoxRow:
        debug ("Appending a Gtk.ListBoxRow");
        this.messages_list.add (row);
        //row.position = this.messages_list.get_n_items ();
        break;
    }
  }*/
}
