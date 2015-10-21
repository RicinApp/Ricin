[GtkTemplate (ui="/chat/tox/ricin/ui/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
  [GtkChild] Gtk.Label username;
  [GtkChild] Gtk.Label status_message;
  [GtkChild] Gtk.ScrolledWindow scroll_messages;
  [GtkChild] Gtk.ListBox messages_list;
  [GtkChild] public Gtk.Entry entry;
  [GtkChild] Gtk.Button send;
  [GtkChild] Gtk.Button send_file;
  [GtkChild] Gtk.Revealer friend_typing;

  private ListStore messages = new ListStore (typeof (Gtk.Label));

  public Tox.Friend fr;
  private weak Tox.Tox handle;
  private weak Gtk.Stack stack;
  private string view_name;

  public ChatView (Tox.Tox handle, Tox.Friend fr, Gtk.Stack stack, string view_name) {
    this.handle = handle;
    this.fr = fr;
    this.stack = stack;
    this.view_name = view_name;

    if (this.fr.name == null) {
      this.username.set_text (this.fr.pubkey);
      this.status_message.set_markup ("");
    }

    this.messages_list.bind_model (this.messages, l => l as Gtk.Widget);
    this.messages_list.size_allocate.connect (() => {
      var adjustment = this.scroll_messages.get_vadjustment ();
      adjustment.set_value (adjustment.get_upper () - adjustment.get_page_size ());
    });

    this.fr.friend_info.connect ((message) => {
      this.add_row (@"<span color=\"#2980b9\">** <i>$message</i></span>");
    });

    this.handle.global_info.connect ((message) => {
      this.add_row (@"<span color=\"#2980b9\">** $message</span>");
    });

    this.entry.activate.connect (this.send_message);
    this.send.clicked.connect (this.send_message);
    this.send_file.clicked.connect (() => {
      var chooser = new Gtk.FileChooserDialog ("Choose a File", null, Gtk.FileChooserAction.OPEN,
          "_Cancel", Gtk.ResponseType.CANCEL,
          "_Open", Gtk.ResponseType.ACCEPT);
      if (chooser.run () == Gtk.ResponseType.ACCEPT) {
        var filename = chooser.get_filename ();
        fr.send_file (filename);
        fr.friend_info (@"Sending file $filename");
      }
      chooser.close ();
    });

    fr.message.connect (message => {
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

      this.add_row (@"<b>$(fr.name):</b> $(Util.add_markup (message))");
    });

    fr.action.connect (message => {
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

      string message_escaped = Util.escape_html (message);
      this.add_row (@"<span color=\"#3498db\">* <b>$(fr.name)</b> $message_escaped</span>");
    });

    fr.file_transfer.connect ((name, size, id) => {
      var window = this.get_ancestor (typeof (Gtk.Window));
      var dialog = new Gtk.MessageDialog ((Gtk.Window) window,
                                          Gtk.DialogFlags.MODAL,
                                          Gtk.MessageType.QUESTION,
                                          Gtk.ButtonsType.NONE,
                                          "File transfer from " + fr.name);
      dialog.secondary_text = @"$name\n$size bytes";
      dialog.add_buttons ("Save", Gtk.ResponseType.ACCEPT, "Cancel", Gtk.ResponseType.CANCEL);
      fr.reply_file_transfer (dialog.run () == Gtk.ResponseType.ACCEPT, id);
      dialog.close ();
    });
    fr.file_done.connect ((name, bytes) => {
      string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";

      // get unique filename
      string filename = name;
      int i = 0;
      while (FileUtils.test (downloads + filename, FileTest.EXISTS)) {
        filename = @"$name-$(++i)";
      }

      FileUtils.set_data (downloads + filename, bytes.get_data ());
      fr.friend_info (@"File downloaded to $downloads$filename");
    });

    fr.bind_property ("connected", entry, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("typing", friend_typing, "reveal_child", BindingFlags.DEFAULT);
    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);
    fr.bind_property ("status-message", status_message, "label", BindingFlags.DEFAULT, (binding, val, ref target) => {
      string status_message = (string) val;
      target.set_string (Util.add_markup (status_message));
      return true;
    });
  }

  private void add_row (string markup) {
    var label = new Gtk.Label (null);
    label.use_markup = true;
    label.halign = Gtk.Align.START;
    label.wrap_mode = Pango.WrapMode.CHAR;
    label.selectable = true;
    label.set_line_wrap (true);
    label.set_markup (markup);
    label.activate_link.connect (this.handle_links);
    messages.append (label);
  }

  private void send_message () {
    var user = this.handle.username;
    string markup;

    var message = this.entry.get_text ();
    if (message.strip () == "") {
      return;
    }

    if (message.has_prefix ("/me ")) {
      var action = message.substring (4);
      var escaped = Util.escape_html (action);
      markup = @"<span color=\"#3498db\">* <b>$user</b> $escaped</span>";
      fr.send_action (action);
    } else {
      markup = @"<b>$user:</b> $(Util.add_markup (message))";
      fr.send_message (message);
    }

    // Add message, clear and focus the entry.
    this.add_row (markup);
    this.entry.text = "";
    this.entry.grab_focus_without_selecting ();
  }

  private bool handle_links (string uri) {
    if (!uri.has_prefix ("tox:")) {
      return false; // Default behavior.
    }

    var main_window = (MainWindow) this.get_ancestor (typeof (MainWindow));
    var toxid = uri.split ("tox:")[1];
    if (toxid.length == ToxCore.ADDRESS_SIZE * 2) {
      main_window.show_add_friend_popover (toxid);
    } else {
      var info_message = "ToxDNS is not supported yet.";
      main_window.notify_message (@"<span color=\"#e74c3c\">$info_message</span>");
    }

    return true;
  }
}
