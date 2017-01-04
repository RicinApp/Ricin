[GtkTemplate (ui="/chat/tox/ricin/ui/group-chat-view.ui")]
class Ricin.GroupChatView : Gtk.Box {
  // Group header.
  [GtkChild] Gtk.Box box_group_infos;
  [GtkChild] Gtk.Image avatar;
  [GtkChild] public Gtk.Label name;
  [GtkChild] Gtk.Label topic;

  // Group menu.
  [GtkChild] Gtk.Button button_toggle_group_menu;
  [GtkChild] Gtk.Revealer revealer_group_menu;
  [GtkChild] Gtk.Label label_group_name;
  [GtkChild] Gtk.Label label_group_topic;

  [GtkChild] Gtk.Label label_friends;
  [GtkChild] Gtk.ListBox listbox_friends;
  [GtkChild] Gtk.Label label_unknown_peers;
  [GtkChild] Gtk.ListBox listbox_unknown_peers;

  [GtkChild] Gtk.Button button_group_leave;
  [GtkChild] Gtk.Button button_group_mute;

  // Invite peers in groupchat.
  [GtkChild] Gtk.Image image_icon_invite_peers;
  [GtkChild] Gtk.Revealer revealer_invite_peers;
  [GtkChild] Gtk.Entry entry_invite_peers;
  [GtkChild] Gtk.Button button_invite_peers;

  // Group content.
  [GtkChild] Gtk.ScrolledWindow scroll_messages;
  [GtkChild] Gtk.ListBox messages_list;

  // Group input.
  [GtkChild] public Gtk.Entry entry;
  [GtkChild] Gtk.Button button_send;

  [Signal (action = true)] private signal void copy_messages_selection ();
  [Signal (action = true)] private signal void quote_messages_selection ();
  [Signal (action = true)] private signal void entry_insert_newline ();

  public Tox.Group group;
  private weak Tox.Tox handle;
  private weak Gtk.Stack stack;
  private Settings settings;
  private string view_name;
  private string last_message = null;
  private bool is_bottom = true;

  // Autocomplete popup.
  private Gtk.ListStore peers = new Gtk.ListStore (1, typeof (string));
  private Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();

  // Constructor.
  public GroupChatView (Tox.Tox handle, Tox.Group group, Gtk.Stack stack, string view_name) {
    this.group = group;
    this.handle = handle;
    this.stack = stack;
    this.view_name = view_name;
    this.settings = Settings.instance;

    this.init_widgets ();
    this.init_signals ();
    this.init_messages_menu ();
    this.init_messages_shortcuts ();
    this.init_completion ();
  }

  private void init_widgets () {
    // Initialize groupchat name.
    if (this.group.name != null) {
      this.name.set_markup (Util.render_emojis (this.group.name));
      this.topic.set_markup (Util.add_markup (this.group.name));
      this.label_group_name.set_markup (Util.render_emojis (this.group.name));
      this.label_group_topic.set_markup (Util.add_markup (this.group.name));

      // Perform ToxIdenticon against the group name.
      Cairo.Surface surface = Util.identicon_for_pubkey (this.group.name);
      var pixbuf_scaled = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
      this.avatar.pixbuf = pixbuf_scaled;
    }

    this.listbox_friends.set_sort_func ((row1, row2) => {
      string peer_name1 = ((GroupListRow) row1).peer.name;
      string peer_name2 = ((GroupListRow) row2).peer.name;
      return Util.sort_az_nocase (peer_name1, peer_name2);
    });

    this.listbox_unknown_peers.set_sort_func ((row1, row2) => {
      string peer_name1 = ((GroupListRow) row1).peer.name;
      string peer_name2 = ((GroupListRow) row2).peer.name;
      return Util.sort_az_nocase (peer_name1, peer_name2);
    });
  }

  private void init_signals () {
    // Handle entry history.
    this.entry.key_press_event.connect ((event) => {
      if (event.keyval == Gdk.Key.Up && this.entry.get_text () == "" && this.last_message != null) {
        this.entry.set_text (this.last_message);
        this.entry.set_position (-1);
        return true;
      } else if (event.keyval == Gdk.Key.Up && this.entry.get_text ().has_prefix ("/topic ")) {
        this.entry.set_text ("/topic %s".printf (this.group.name));
        this.entry.set_position (-1);
        return true;
      } else if (event.keyval == Gdk.Key.Down && this.entry.get_text () == this.last_message) {
        this.entry.set_text ("");
      }
      return false;
    });

    // Keep group name in sync.
    this.group.title_changed.connect ((peer, title) => {
      this.name.set_markup (Util.render_emojis (this.group.name));
      this.topic.set_markup (Util.add_markup (this.group.name));
      this.label_group_name.set_markup (Util.render_emojis (this.group.name));
      this.label_group_topic.set_markup (Util.add_markup (this.group.name));

      Cairo.Surface surface = Util.identicon_for_pubkey (this.group.name, 48);
      var pixbuf_scaled = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
      this.avatar.pixbuf = pixbuf_scaled;

      string message = "";
      if (this.group.peers[peer].name == null) {
        message = _("The topic was set to « %s ».").printf (title);
      } else {
        message = _("%s set the topic to « %s ».").printf (this.group.peers[peer].name, title);
      }

      InfoListRow row = new InfoListRow (message);
      this.messages_list.add (row);
    });

    this.group.message.connect ((peer, message) => {
      debug ("New message from group %d: [Peer %d] %s", this.group.num, peer.num, message);
      string current_time = time ();
      if (message.index_of (">", 0) == 0) {
        string markup = Util.add_markup (message);
        var msg = new QuoteMessageListRow (this.handle, null, markup, current_time, -1, false);
        msg.author = peer.name;
        msg.label_name.set_text (peer.name);
        msg.image_author.set_tooltip_text (peer.name);
        msg.image_author.pixbuf = Util.pubkey_to_image (peer.pubkey, 24, 24);
        msg.stack.set_visible_child_name ("timestamp");
        this.messages_list.add (msg);
      } else {
        string markup = Util.add_markup (message);
        var msg = new MessageListRow (this.handle, null, markup, current_time, -1, false);
        msg.author = peer.name;
        msg.label_name.set_text (peer.name);
        msg.image_author.set_tooltip_text (peer.name);
        msg.image_author.pixbuf = Util.pubkey_to_image (peer.pubkey, 24, 24);
        msg.stack.set_visible_child_name ("timestamp");
        this.messages_list.add (msg);
      }

      ((MainWindow) this.get_toplevel ()).set_desktop_hint (true);
    });

    this.group.action.connect ((peer, message) => {
      string current_time = time ();
      string message_escaped = @"<b>$(peer.name)</b> $(Util.escape_html(message))";
      this.messages_list.add (new SystemMessageListRow (message_escaped));

      ((MainWindow) this.get_toplevel ()).set_desktop_hint (true);
    });

    this.group.peer_count_changed.connect (() => {
      this.label_unknown_peers.set_markup ("%s (%d)".printf (
        _("<b>Unknown peers</b>"), (int)this.listbox_unknown_peers.get_children ().length ())
      );
      this.label_friends.set_markup ("%s (%d)".printf (
        _("<b>Friends</b>"), (int)this.listbox_friends.get_children ().length ())
      );

      this.refresh_peers_list ();
    });

    this.group.peer_added.connect (peer => {
      if (peer.pubkey == this.handle.pubkey) {
        return;
      }

      DateTime now = new DateTime.now_local ();
      DateTime init_time = this.group.joined_time.add_seconds (10);
      if (init_time.compare (now) == -1) { // Avoid spam when joining a group.
        if (peer.name != "Tox User") {
          InfoListRow info_row = new InfoListRow (_("%s joined the group.").printf (peer.name));
          this.messages_list.add (info_row);
        }
      }
    });

    this.group.peer_removed.connect ((peer_num, peer_pubkey, peer_name) => {
      if (peer_pubkey == this.handle.pubkey) {
        return;
      }

      InfoListRow info_row = new InfoListRow (_("%s left the group.").printf (peer_name));
      this.messages_list.add (info_row);
    });
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

  private void init_messages_shortcuts () {
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
    * Shortcut for Shift+Q: Quote selected messages if selection > 0
    **/
    this.add_accelerator (
      "quote-messages-selection", MainWindow.accel_group, Gdk.keyval_from_name("Q"),
      Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE
    );

    this.quote_messages_selection.connect (() => {
      if (this.messages_selected () == true) {
        string quote = this.get_selected_messages (true, false);
        this.entry.set_text (quote);
        this.messages_list.unselect_all ();
        this.entry.grab_focus_without_selecting ();
        this.entry.set_position (-1);
      }
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

  private void init_completion () {
    this.entry.set_completion (this.completion);

    this.completion.set_model (this.peers);
    this.completion.set_text_column (0);

    this.completion.inline_selection = true;
    this.completion.inline_completion = true;
    this.completion.popup_completion = true;
    this.completion.popup_set_width = false;
  }

  private void refresh_peers_list () {
    Tox.Peer[] peers = this.handle.get_peers_for_group (this.group.num);

    // Clear both peers listbox.
    this.listbox_friends.forall ((element) => {
      this.listbox_friends.remove (element);
    });

    this.listbox_unknown_peers.forall ((element) => {
      this.listbox_unknown_peers.remove (element);
    });

    // Clear the listStore.
    this.peers.clear ();

    // Add peers in the correct listbox + liststore for completion.
    Gtk.TreeIter iter;
    for (int i = 0; i < peers.length; i++) {
      Tox.Peer peer = peers[i];

      if (peer.pubkey == this.handle.pubkey) {
        continue;
      }

      GroupListRow row = new GroupListRow (peer);
      row.init_mute_button ();

      if (this.handle.has_friend (peer.pubkey)) {
        peer.notify["name"].connect (() => {
          this.listbox_friends.invalidate_sort ();
        });
        this.listbox_friends.insert (row, peer.num);
      } else {
        peer.notify["name"].connect (() => {
          this.listbox_unknown_peers.invalidate_sort ();
        });
        this.listbox_unknown_peers.insert (row, peer.num);
      }

      this.peers.append (out iter);
      this.peers.set (iter, 0, peer.name);
    }

    this.listbox_friends.invalidate_sort ();
    this.listbox_unknown_peers.invalidate_sort ();
  }

  private string time () {
    return new DateTime.now_local ().format ("%H:%M:%S %p");
  }

  /**
  * Clear the current groupchat content.
  **/
  private void clear () {
    List<weak Gtk.Widget> childs = this.messages_list.get_children ();
    foreach (Gtk.Widget m in childs) {
      this.messages_list.remove (m);
    }
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
      } else if (item is InfoListRow) {
        name = "* ";
        txt = ((InfoListRow) item).message;
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

  // Callback: Send message.
  [GtkCallback]
  private void send_message () {
    string user = this.handle.username;
    string message = this.entry.get_text ();
    string current_time = time ();

    string markup;

    if (message.strip () == "") {
      return;
    } else if (message.strip () == "/clear") {
      this.clear ();
      this.entry.text = "";
      return;
    }

    this.last_message = message;

    if (message.has_prefix ("/me ")) { // Actions.
      string action = message.substring (4);
      string escaped = Util.escape_html (action);
      markup = @"<b>$user</b> $escaped";

      this.messages_list.add (new SystemMessageListRow (markup));
      this.group.send_action (action);
    } else if (message.has_prefix ("/topic ")) { // Group title.
      string topic = message.substring (7);
      this.group.set_title (topic);
    } else if (message.index_of (">", 0) == 0) { // Quotes.
      markup = Util.add_markup (message);
      uint32 message_id = (uint32)this.group.send_message (message);
      var msg = new QuoteMessageListRow (this.handle, null, markup, current_time, message_id, false);
      msg.stack.set_visible_child_name ("timestamp");
      this.messages_list.add (msg);
    } else { // Message.
      markup = Util.add_markup (message);
      uint32 message_id = (uint32)this.group.send_message (message);
      var msg = new MessageListRow (this.handle, null, markup, time (), message_id, false);
      msg.stack.set_visible_child_name ("timestamp");
      this.messages_list.add (msg);
    }

    // clear the entry
    this.entry.text = "";
  }

  // Callback: Invite preer in groupchat.
  [GtkCallback]
  private void toggle_invite_peers () {
    this.revealer_invite_peers.notify["child-revealed"].connect (() => {
      if (this.revealer_invite_peers.child_revealed) {
        this.image_icon_invite_peers.set_from_icon_name ("window-close-symbolic", Gtk.IconSize.DND);
        this.entry_invite_peers.grab_focus_without_selecting ();
      } else {
        this.image_icon_invite_peers.set_from_icon_name ("list-add-symbolic", Gtk.IconSize.DND);
        this.entry.grab_focus_without_selecting ();
      }
    });

    this.revealer_invite_peers.set_reveal_child (!this.revealer_invite_peers.child_revealed);
  }

  // Callback: Toggle group menu.
  [GtkCallback]
  private void toggle_group_menu () {
    this.revealer_group_menu.set_reveal_child (!this.revealer_group_menu.child_revealed);
    this.entry.grab_focus_without_selecting ();
  }

  // Callback: Leave the group.
  [GtkCallback]
  private void leave_group () {
    var main_window = ((MainWindow) this.get_toplevel ());
    if (main_window != null) {
      main_window.remove_group (this.group);
    }
  }

  // Callback: Mute the group (no notifications).
  [GtkCallback]
  private void mute_group () {
    this.group.muted = !this.group.muted;
    if (this.group.muted) {
      this.button_group_mute.label = _("Unmute");
    } else {
      this.button_group_mute.label = _("Mute");
    }
  }

  [GtkCallback]
  private void peer_row_clicked (Gtk.ListBoxRow listbox_row) {
    GroupListRow row = (GroupListRow) listbox_row;
    string peer_name = row.peer.name;
    int cursor_position = this.entry.get_position ();

    string buffer = "";
    if (cursor_position == 0) { // Start of the line, insert `$(peer_name): `.
      buffer = @"$(peer_name): ";
    } else { // Anywhere else, insert `$(peer_name)`.
      buffer = peer_name;
    }

    this.entry.insert_at_cursor (buffer);
    this.entry.grab_focus_without_selecting ();
    this.entry.set_position (cursor_position + buffer.length);
  }

  // Last scroll pos.
  private double _bottom_scroll = 0.0;

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
    } else {
      this.is_bottom = false;
    }

    this._bottom_scroll = adj.value;
  }
}
