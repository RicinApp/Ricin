[GtkTemplate (ui="/chat/tox/Ricin/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
  [GtkChild] Gtk.ListBox messages_list;
  [GtkChild] Gtk.Entry entry;
  [GtkChild] Gtk.Button send;
  [GtkChild] Gtk.Revealer friend_typing;

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
    this.send.clicked.connect (() => this.send_message ());

    fr.message.connect (message => {
      string message_escaped = Util.escape_html (message);
      if (message[0] == '>') {
        var regex = new Regex ("^&gt;(.*)+?", RegexCompileFlags.MULTILINE);
        var quote = regex.replace (message_escaped, message_escaped.length, 0, "<span color=\"#2ecc71\">>\\1</span>");
        this.add_row (@"<b>$(fr.name):</b> $quote");
      } else {
        this.add_row (@"<b>$(fr.name):</b> $message_escaped");
      }
    });

    fr.action.connect (message => {
      string message_escaped = Util.escape_html (message);
      this.add_row (@"<span color=\"#3498db\">* <b>$(fr.name)</b> $message_escaped</span>");
    });

    fr.notify["typing"].connect ((obj, prop) => {
      friend_typing.set_reveal_child (fr.typing);
    });
  }

  private void send_message () {
    var user = this.handle.username;
    var message = this.entry.get_text ();
    var message_escaped = Util.escape_html (message);
    var markup = "";

    if (message.strip () == "")
      return;

    if (message.has_prefix ("/me ")) {
      // Ugly.
      message = message.splice(0, 4); // Removes the "/me " part.
      message_escaped = message_escaped.slice(0, 4);
      markup = @"<span color=\"#3498db\">* <b>$user</b> $message_escaped</span>";
      fr.send_action (message);
    } else if (message[0] == '>') {
      var regex = new Regex ("^&gt;(.*)+?", RegexCompileFlags.MULTILINE);
      var quote = regex.replace (message_escaped, message_escaped.length, 0, "<span color=\"#2ecc71\">>\\1</span>");
      markup = @"<b>$user:</b> $quote";
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
