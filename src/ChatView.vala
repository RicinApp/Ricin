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

  /* Markdown help popover */
  [GtkChild] Gtk.Box box_popover_markdown_help;
  [GtkChild] Gtk.Button button_show_markdown_help;
  Gtk.Popover popover_markdown_help;

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

  [Signal (action = true)] private signal void copy_messages_selection ();
  [Signal (action = true)] private signal void quote_messages_selection ();
  [Signal (action = true)] private signal void entry_insert_newline ();

  public Tox.Friend fr;
  private weak Tox.Tox handle;
  private weak Gtk.Stack stack;
  private string view_name;
  private HistoryManager history;
  private Settings settings;

  private Tox.UserStatus last_status;
  private string last_message_sender { get; set; default = "ricin"; }
  private string last_message = null;
  private bool is_bottom = true;
  private ViewType view_type;

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

  private enum ViewType {
    FULL,
    COMPACT
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
    this.settings = Settings.instance;

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
      var pixbuf_scaled = new Gdk.Pixbuf.from_file_at_scale (_avatar_path, 48, 48, false);
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (_avatar_path, 128, 128, false);

      this.user_avatar.pixbuf = pixbuf_scaled;
      this.friend_profil_avatar.pixbuf = pixbuf;
    } else {
      Cairo.Surface surface = Util.identicon_for_pubkey (this.fr.pubkey);
      var pixbuf_scaled = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
      this.user_avatar.pixbuf = pixbuf_scaled;
      this.friend_profil_avatar.pixbuf = Util.pubkey_to_image(this.fr.pubkey, 128, 128);
    }

    this.entry.key_press_event.connect ((event) => {
      if (event.keyval == Gdk.Key.Up && this.entry.get_text () == "" && this.last_message != null) {
        this.entry.set_text (this.last_message);
        this.entry.set_position (-1);
        return true;
      } else if (event.keyval == Gdk.Key.Down && this.entry.get_text () == this.last_message) {
        this.entry.set_text ("");
      }
      return false;
    });

    if (this.settings.compact_mode) {
      this.switch_view_type (ViewType.COMPACT);
    } else {
      this.switch_view_type (ViewType.FULL);
    }

    this.settings.notify["compact-mode"].connect (() => {
      if (this.settings.compact_mode) {
        this.switch_view_type (ViewType.COMPACT);
      } else {
        this.switch_view_type (ViewType.FULL);
      }
    });

    this.init_messages_menu ();
    this.init_messages_shortcuts ();

    this.popover_markdown_help = new Gtk.Popover (this.button_show_markdown_help);
    //set popover content
    this.popover_markdown_help.set_size_request (250, 150);
    this.popover_markdown_help.set_position (Gtk.PositionType.BOTTOM | Gtk.PositionType.RIGHT);
    this.popover_markdown_help.set_modal (false);
    this.popover_markdown_help.set_transitions_enabled (true);
    this.popover_markdown_help.add (this.box_popover_markdown_help);

    this.popover_markdown_help.closed.connect (() => {
      this.entry.grab_focus_without_selecting ();
    });

    this.button_show_markdown_help.clicked.connect (() => {
      if (this.popover_markdown_help.visible == false) {
        this.popover_markdown_help.show_all ();
      } else {
        this.popover_markdown_help.hide ();
      }

      // Avoid the user to loose focus with chat entry.
      this.entry.grab_focus_without_selecting ();
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

    this.entry.paste_clipboard.connect (this.paste_clipboard);

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

      ((MainWindow) this.get_toplevel ()).set_desktop_hint (true);
    });

    fr.avatar.connect (p => {
      this.user_avatar.pixbuf = p;
      //this.friend_profil_avatar.pixbuf = p;
      this.friend_profil_avatar.pixbuf = Util.pubkey_to_image(this.fr.pubkey, 128, 128);

      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));
    });

    fr.message.connect (message => {
      var current_time = time ();
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

      var visible_child = this.stack.get_visible_child_name ();
      var main_window = ((MainWindow) this.get_toplevel ());

      if (visible_child != this.view_name) {
        var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
        if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 46, 46, true);

          if (this.handle.status != Tox.UserStatus.BUSY) {
            Notification.notify (this.fr.name, message, 5000, pixbuf);
          }
        } else {
          if (this.handle.status != Tox.UserStatus.BUSY) {
            Notification.notify (this.fr.name, message, 5000, Util.pubkey_to_image (this.fr.pubkey, 46, 46));
          }
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

      ((MainWindow) this.get_toplevel ()).set_desktop_hint (true);
    });

    fr.action.connect (message => {
      var current_time = time ();
      this.label_friend_last_seen.set_markup (this.fr.last_online ("%H:%M %d/%m/%Y"));

      var visible_child = this.stack.get_visible_child_name ();
      if (visible_child != this.view_name) {

        var avatar_path = Tox.profile_dir () + "avatars/" + this.fr.pubkey + ".png";
        if (FileUtils.test (avatar_path, FileTest.EXISTS)) {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale (avatar_path, 46, 46, true);

          if (this.handle.status != Tox.UserStatus.BUSY) {
            Notification.notify (fr.name, message, 5000, pixbuf);
          }
        } else {
          if (this.handle.status != Tox.UserStatus.BUSY) {
            Notification.notify (fr.name, message, 5000, Util.pubkey_to_image (this.fr.pubkey, 46, 46));
          }
        }

      }

      this.history.write (this.fr.pubkey, @"[$current_time] ** $(this.fr.name) $message");

      string message_escaped = @"<b>$(Util.escape_html(fr.name))</b> $(Util.escape_html(message))";
      this.last_message_sender = "friend";
      messages_list.add (new SystemMessageListRow (message_escaped));
      //this.add_row (MessageRowType.Action, new SystemMessageListRow (message_escaped));

      ((MainWindow) this.get_toplevel ()).set_desktop_hint (true);
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
      if (file_content_type.has_prefix ("image/")) {
        this.last_message_sender = "friend";
        var image_row = new FileListRow (this.handle, fr, id, fr.name, path, size, time ());
        image_row.accept_file.connect ((response, file_id) => {
          fr.reply_file_transfer (response, file_id);
        });
        messages_list.add (image_row);
      } else {
        this.last_message_sender = "friend";
        var file_row = new FileListRow (this.handle, fr, id, fr.name, path, size, time ());
        file_row.accept_file.connect ((response, file_id) => {
          fr.reply_file_transfer (response, file_id);
        });
        messages_list.add (file_row);
      }

      ((MainWindow) this.get_toplevel ()).set_desktop_hint (true);
    });

    fr.bind_property ("connected", entry, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send_file, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", button_show_emoticons, "sensitive", BindingFlags.DEFAULT);
    //fr.bind_property ("typing", friend_typing, "reveal_child", BindingFlags.DEFAULT);
    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);

    this.entry.changed.connect (() => {
      bool send_typing_notification = this.settings.send_typing_status;
      if (!send_typing_notification) {
        return;
      }
      var is_typing = (this.entry.text.strip () != "");
      this.fr.send_typing (is_typing);
    });
    this.entry.backspace.connect (() => {
      bool send_typing_notification = this.settings.send_typing_status;
      if (!send_typing_notification) {
        return;
      }
      var is_typing = (this.entry.text.strip () != "");
      this.fr.send_typing (is_typing);
    });

    this.fr.notify["typing"].connect ((obj, prop) => {
      if (!this.settings.show_typing_status) {
        return;
      }

      string friend_name = Util.escape_html (this.fr.name);
      this.label_friend_is_typing.set_markup (@"<i>$friend_name " + _("is typing") + "</i>");
      this.friend_typing.reveal_child = this.fr.typing;
    });

    /*this.friend_typing.notify["child-revealed"].connect (() => {
      Gtk.Adjustment adj = this.scroll_messages.get_vadjustment ();
      if (adj.value == this._bottom_scroll) {
        this.scroll_bottom ();
      }
    });*/

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

      bool display_friends_status_changes = this.settings.show_status_changes;
      if (this.fr.last_status != this.fr.status && display_friends_status_changes) {
        var status_str = Util.status_to_string (this.fr.status);
        this.last_message_sender = "friend";
        messages_list.add (new StatusMessageListRow (fr.name + _(" is now ") + status_str, status));
      }
      this.fr.last_status = this.fr.status;
    });
  }

  private void switch_view_type (ViewType type) {
    /*if (type == ViewType.FULL) {
      foreach (Gtk.Widget item in this.messages_list.get_children ()) {
        if (item is MessageListRow) {
          ((MessageListRow) item).label_name.visible = true;
          ((MessageListRow) item).image_author.visible = false;
        } else if (item is QuoteMessageListRow) {
          ((QuoteMessageListRow) item).label_name.visible = true;
          ((QuoteMessageListRow) item).image_author.visible = false;
        } else if (item is FileListRow) {
          ((FileListRow) item).label_name.visible = true;
          ((FileListRow) item).image_author.visible = false;
        }
      }
    } else if (type == ViewType.COMPACT) {
      foreach (Gtk.Widget item in this.messages_list.get_children ()) {
        if (item is MessageListRow) {
          ((MessageListRow) item).label_name.visible = false;
          ((MessageListRow) item).image_author.visible = true;
        } else if (item is QuoteMessageListRow) {
          ((QuoteMessageListRow) item).label_name.visible = false;
          ((QuoteMessageListRow) item).image_author.visible = true;
        } else if (item is FileListRow) {
          ((FileListRow) item).label_name.visible = false;
          ((FileListRow) item).image_author.visible = true;
        }
      }
    }

    this.view_type = type;*/
  }

  private bool messages_selected () {
    return (this.messages_list.get_selected_rows ().length () > 0);
  }

  private string get_selected_messages (bool as_quote, bool include_names) {
    StringBuilder sb = new StringBuilder ();
    foreach (Gtk.ListBoxRow item in this.messages_list.get_selected_rows ()) {
      string name = "";
      string txt = "";

      if (item is MessageListRow) {
        name = "[" + ((MessageListRow) item).author + "]";
        txt  = ((MessageListRow) item).label_message.get_text ();
      } else if (item is SystemMessageListRow) {
        name = "* ";
        txt  = ((SystemMessageListRow) item).label_message.get_text ();
      } else if (item is QuoteMessageListRow) {
        name = "[" + ((QuoteMessageListRow) item).author + "]";
        txt  = ((QuoteMessageListRow) item).get_quote ();
      }

      if (as_quote) {
        sb.append_c ('>');
      }
      if (include_names) {
        sb.append (@"$name ");
      }

      sb.append (txt);
      sb.append_c ('\n');
    }

    sb.truncate (sb.len - 1);
    return (string) sb.data;
  }

  public void init_messages_menu () {
    var menu = new Gtk.Menu ();

    var menu_copy_selection = new Gtk.ImageMenuItem.with_label (_("Copy selection in clipboard"));
    var label_copy_selection = ((Gtk.AccelLabel) menu_copy_selection.get_child ());
    label_copy_selection.set_accel (Gdk.keyval_from_name("C"), Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK);
    menu_copy_selection.always_show_image = true;
    menu_copy_selection.set_image (new Gtk.Image.from_icon_name ("edit-copy-symbolic", Gtk.IconSize.MENU));

    var menu_copy_quote = new Gtk.ImageMenuItem.with_label (_("Copy quote in clipboard"));
    menu_copy_quote.always_show_image = true;
    menu_copy_quote.set_image (new Gtk.Image.from_icon_name ("edit-copy-symbolic", Gtk.IconSize.MENU));

    var menu_quote_selection = new Gtk.ImageMenuItem.with_label (_("Quote selection"));
    var label_quote_selection = ((Gtk.AccelLabel) menu_quote_selection.get_child ());
    label_quote_selection.set_accel (Gdk.keyval_from_name("Q"), Gdk.ModifierType.SHIFT_MASK);
    menu_quote_selection.always_show_image = true;
    menu_quote_selection.set_image (new Gtk.Image.from_icon_name ("insert-text-symbolic", Gtk.IconSize.MENU));

    var menu_remove_selection = new Gtk.ImageMenuItem.with_label (_("Delete selected messages"));
    menu_remove_selection.always_show_image = true;
    menu_remove_selection.set_image (new Gtk.Image.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.MENU));

    var menu_clear_chat = new Gtk.ImageMenuItem.with_label (_("Clear conversation"));
    menu_clear_chat.always_show_image = true;
    menu_clear_chat.set_image (new Gtk.Image.from_icon_name ("edit-clear-all-symbolic", Gtk.IconSize.MENU));


    menu_copy_selection.activate.connect (() => {
      if (this.messages_selected () == false) {
        return;
      }

      string selection = this.get_selected_messages (false, true);
      Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (selection, -1);
      this.messages_list.unselect_all ();
      this.entry.grab_focus_without_selecting ();
      this.entry.set_position (-1);
    });
    menu_copy_quote.activate.connect (() => {
      if (this.messages_selected () == false) {
        return;
      }

      string quote = this.get_selected_messages (true, true);
      Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (quote, -1);
      this.messages_list.unselect_all ();
      this.entry.grab_focus_without_selecting ();
      this.entry.set_position (-1);
    });
    menu_quote_selection.activate.connect (() => {
      if (this.messages_selected () == false) {
        return;
      }

      string quote = this.get_selected_messages (true, false);
      this.entry.set_text (quote);
      this.messages_list.unselect_all ();
      this.entry.grab_focus_without_selecting ();
      this.entry.set_position (-1);
    });
    menu_remove_selection.activate.connect (() => {
      if (this.messages_selected () == false) {
        return;
      }

      List<weak Gtk.Widget> childs = this.messages_list.get_selected_rows ();
      foreach (Gtk.Widget m in childs) {
        this.messages_list.remove (m);
      }
    });
    menu_clear_chat.activate.connect(this.clear);

    menu.append (menu_copy_selection);
    menu.append (menu_copy_quote);
    menu.append (menu_quote_selection);
    menu.append (new Gtk.SeparatorMenuItem ());
    menu.append (menu_remove_selection);
    menu.append (menu_clear_chat);
    menu.show_all ();

    this.messages_list.button_press_event.connect ((e) => {
      // Only allow messages operations if some messages are selected.
      if (this.messages_list.get_selected_rows ().length () < 1) {
        menu_copy_quote.sensitive = false;
        menu_copy_selection.sensitive = false;
        menu_quote_selection.sensitive = false;
        menu_remove_selection.sensitive = false;
      } else {
        menu_copy_quote.sensitive = true;
        menu_copy_selection.sensitive = true;
        menu_quote_selection.sensitive = true;
        menu_remove_selection.sensitive = true;
      }

      // Only allow chatview to be cleared if it contains messages.
      if (this.messages_list.get_children ().length () < 1) {
        menu_clear_chat.sensitive = false;
      } else {
        menu_clear_chat.sensitive = true;
      }

      // If the event was a right click.
      if (e.button != 3) {
        return false;
      }

      menu.popup (null, null, null, 3, Gtk.get_current_event_time ());
      return true;
    });
  }

  /*private MainWindow get_top () {

  }*/

  private void init_messages_shortcuts () {
    //var main_window = ((MainWindow) this.get_toplevel ().get_toplevel ());

    /**
    * Shortcut for Ctrl+Shift+C: Copy selected messages if selection > 0
    **/
    this.add_accelerator (
      "copy-messages-selection", MainWindow.accel_group, Gdk.keyval_from_name("C"),
      Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE
    );

    this.copy_messages_selection.connect (() => {
      if (this.messages_selected () == false) {
        return;
      }

      string selection = this.get_selected_messages (false, true);
      Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).set_text (selection, -1);
      this.messages_list.unselect_all ();
      this.entry.grab_focus_without_selecting ();
      this.entry.set_position (-1);
    });

    /**
    * Shortcut for Ctrl+Shift+Q: Quote selected messages if selection > 0
    **/
    this.add_accelerator (
      "quote-messages-selection", MainWindow.accel_group, Gdk.keyval_from_name("Q"),
      Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE
    );

    this.quote_messages_selection.connect (() => {
      if (this.messages_selected () == false) {
        return;
      }

      string quote = this.get_selected_messages (true, false);
      this.entry.set_text (quote);
      this.messages_list.unselect_all ();
      this.entry.grab_focus_without_selecting ();
      this.entry.set_position (-1);
    });

    /**
    * Shortcut for Shift+Enter in this.entry: Add a newline (\n).
    **/
    this.add_accelerator (
      "entry-insert-newline", MainWindow.accel_group, Gdk.Key.Return,
      Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE
    );

    this.entry_insert_newline.connect (() => {
      debug ("entry_insert_newline: Called.");

      int cursor_position = this.entry.get_position ();
      string text = this.entry.get_text ();
      string newline = "\n";

      this.entry.insert_at_cursor (newline);
      this.entry.grab_focus_without_selecting ();
      this.entry.set_position (cursor_position + newline.length);

    });
  }

  public void show_notice (string text, string icon_name = "help-info-symbolic") {
    this.image_notify.icon_name = icon_name;
    this.label_notify_text.set_text (text);
    this.button_notify_close.clicked.connect (() => {
      this.notify.set_reveal_child (false);
    });

    this.notify.set_reveal_child (true);
    this.scroll_to_bottom ();
  }

  private void clear () {
    List<weak Gtk.Widget> childs = this.messages_list.get_children ();
    foreach (Gtk.Widget m in childs) {
      this.messages_list.remove (m);
    }
  }

  public void paste_clipboard () {
    Gtk.Clipboard clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
    Gdk.Pixbuf image = clipboard.wait_for_image ();

    Rand rnd = new Rand.with_seed ((uint32)new DateTime.now_local ().hash ());
    uint32 rnd_id = rnd.next_int ();
    string image_name = @"ricin-$rnd_id.png";

    if (image != null) { // Cool, the content is an image, let's send it to our friend!
      uint32 file_id = this.fr.send_image (image, image_name);

      // Finally, add the inline image to the ChatView
      var image_widget = new FileListRow (
        this.handle, this.fr, file_id, this.handle.username,
        "", image.get_byte_length (), time (), false, image, image_name
      );
      messages_list.add (image_widget);
    }
  }

  [GtkCallback]
  public void toggle_friend_menu () {
    this.revealer_friend_menu.set_reveal_child (!this.revealer_friend_menu.child_revealed);
    this.entry.grab_focus_without_selecting ();
  }

  [GtkCallback]
  private void delete_friend () {
    var main_window = ((MainWindow) this.get_toplevel ());
    main_window.remove_friend (this.fr);
  }

  [GtkCallback]
  public void block_friend () {
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
    if (message.strip () == "") {
      return;
    } else if (message.strip () == "/clear") {
      this.clear ();

      this.entry.text = "";
      return;
    }
    this.last_message = message;
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
        var image_widget = new FileListRow (
          this.handle, fr, file_id, this.handle.username,
          file.get_path (), size, time (), true
        );
        //image_widget.button_save_inline.visible = false;
        messages_list.add (image_widget);
      } else {
        //fr.friend_info (@"Sending file $filename");
        var file_row = new FileListRow (
          this.handle, fr, file_id, this.handle.username,
          filename, size, time (), false
        );
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
    if (this._bottom_scroll == adj.value || this._bottom_scroll == 0.0) {
      adj.set_value (adj.get_upper () - adj.get_page_size ());
      this.is_bottom = true;

      if (this.settings.show_unread_messages) {
        this.revealer_unread_messages.set_reveal_child (false);
      }
    } else {
      this.is_bottom = false;
      if (this.settings.show_unread_messages) {
        this.revealer_unread_messages.set_reveal_child (true);
      }
    }

    this._bottom_scroll = adj.value;
  }

  [GtkCallback]
  private void unread_messages_scroll () {
    this.revealer_unread_messages.notify["child-revealed"].connect (() => {
      if (this.revealer_unread_messages.reveal_child == false) {
        this.scroll_bottom ();
        this.entry.grab_focus_without_selecting ();
      }
    });
    if (this.revealer_unread_messages.reveal_child == true) {
      this.revealer_unread_messages.set_reveal_child (false);
    }
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
