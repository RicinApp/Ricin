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
  }

  private void init_widgets () {
    // Initialize groupchat name.
    if (this.group.name != null) {
      this.name.set_text (this.group.name);
      this.topic.set_markup (Util.add_markup (this.group.name));
      this.label_group_name.set_text (this.group.name);
      this.label_group_topic.set_markup (Util.add_markup (this.group.name));

      // Perform ToxIdenticon against the group name.
      Cairo.Surface surface = Util.identicon_for_pubkey (this.group.name);
      var pixbuf_scaled = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
      this.avatar.pixbuf = pixbuf_scaled;
    }
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
      this.name.set_text (this.group.name);
      this.topic.set_markup (Util.add_markup (this.group.name));
      this.label_group_name.set_text (this.group.name);
      this.label_group_topic.set_markup (Util.add_markup (this.group.name));

      Cairo.Surface surface = Util.identicon_for_pubkey (this.group.name, 48);
      var pixbuf_scaled = Gdk.pixbuf_get_from_surface (surface, 0, 0, 48, 48);
      this.avatar.pixbuf = pixbuf_scaled;
    });

    this.group.message.connect ((peer, message) => {
      print ("New message from group %d: [Peer %d] %s\n", this.group.num, peer.num, message);
    
      string current_time = time ();
      if (message.index_of (">", 0) == 0) {
        string markup = Util.add_markup (message);
        var msg = new QuoteMessageListRow (this.handle, null, markup, current_time, -1, false);
        msg.label_name.set_text (peer.name);
        msg.image_author.set_tooltip_text (peer.name);
        msg.image_author.pixbuf = Util.pubkey_to_image (peer.pubkey, 24, 24);
        msg.stack.set_visible_child_name ("timestamp");
        this.messages_list.add (msg);
      } else {
        string markup = Util.add_markup (message);
        var msg = new MessageListRow (this.handle, null, markup, current_time, -1, false);
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
      this.label_unknown_peers.set_markup ("%s (%d)".printf (_("<b>Unknown peers</b>"), this.group.peers_count));
    });

    this.group.peer_added.connect (peer => {
      GroupListRow row = new GroupListRow (peer);
      this.listbox_unknown_peers.insert (row, peer.num);
    });

    this.group.peer_removed.connect (peer_num => {
      Gtk.ListBoxRow row = this.listbox_unknown_peers.get_row_at_index (peer_num);
      this.listbox_unknown_peers.remove (row);
    });
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
    main_window.remove_group (this.group);
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
    } else {
      this.is_bottom = false;
    }

    this._bottom_scroll = adj.value;
  }
  
  private void scroll_bottom () {
    Gtk.Adjustment adj = this.scroll_messages.get_vadjustment ();
    adj.set_value (adj.get_upper () - adj.get_page_size ());
    this._bottom_scroll = adj.get_upper () - adj.get_page_size ();
    this.is_bottom = true;
  }
}
