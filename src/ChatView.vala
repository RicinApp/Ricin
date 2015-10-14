[GtkTemplate (ui="/chat/tox/Ricin/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
  [GtkChild] Gtk.ListBox messages_list;
  [GtkChild] Gtk.Entry entry;
  [GtkChild] Gtk.Button send;

  private ListStore messages = new ListStore (typeof (Gtk.Label));

  private weak Tox.Tox handle;
  public Tox.Friend fr;

  private void add_row (string markup) {
    var label = new Gtk.Label (null);
    label.use_markup = true;
    label.set_markup (markup);
    label.halign = Gtk.Align.START;
    label.set_line_wrap (true);
    messages.append (label);
  }

  public ChatView (Tox.Tox handle, Tox.Friend fr) {
    this.handle = handle;
    this.fr = fr;
    this.messages_list.bind_model (this.messages, l => l as Gtk.Widget);

    this.handle.system_message.connect ((message) => {
      this.add_row (@"<span color=\"#2980b9\">** <i>$message</i></span>");
    });

    this.entry.activate.connect (this.send_message);

    send.clicked.connect (() => this.send_message ());

    fr.message.connect (message => {
      var label = new Gtk.Label ("");
      label.halign = Gtk.Align.START;
      label.use_markup = true;
      label.set_line_wrap (true);

      if (message.has_prefix (">")) {
        var regex = new Regex (">(.*)");
        var quote = regex.replace (message, message.length, 0, "<span color=\"#2ecc71\">>\\1</span>");
        label.set_markup (@"<b>$(fr.name):</b> " + quote);
      } else {
        label.set_markup (@"<b>$(fr.name):</b> $message");
      }
      messages.append (label);
    });

    fr.action.connect (message => {
      this.add_row (@"<span color=\"#3498db\">* <b>$(fr.name)</b> $message</span>");
    });
  }

  private void send_message () {
    var user = this.handle.username;
    var message = this.entry.get_text ();
    var markup = "";

    if (message.has_prefix ("/me ")) {
      message = message.splice(0, 4); // Removes the "/me " part.
      markup = @"<span color=\"#3498db\">* <b>$user</b> $message</span>";
      fr.send_action (message);
    } else if (message.has_prefix (">")) {
      var regex = new Regex (">(.*)");
      var quote = regex.replace (message, message.length, 0, "<span color=\"#2ecc71\">>\\1</span>");
      markup = @"<b>$user:</b> " + quote;
      fr.send_message (message);
    } else {
      markup = @"<b>$user:</b> $message";
      fr.send_message (message);
    }

    this.add_row (markup);

    // Clear and focus the entry.
    this.entry.text = "";
    this.entry.grab_focus_without_selecting ();
  }
}
