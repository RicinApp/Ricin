[GtkTemplate (ui="/chat/tox/Ricin/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
  [GtkChild] Gtk.Label username;
  [GtkChild] Gtk.Label status_message;
  [GtkChild] Gtk.ListBox messages_list;
  [GtkChild] public Gtk.Entry entry;
  [GtkChild] Gtk.Button send;
  [GtkChild] Gtk.Revealer friend_typing;

  private ListStore messages = new ListStore (typeof (Gtk.Label));

  private weak Tox.Tox handle;
  public Tox.Friend fr;

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
      this.add_row (@"<b>$(fr.name):</b> $(Util.add_markup (message))");
    });

    fr.action.connect (message => {
      string message_escaped = Util.escape_html (message);
      this.add_row (@"<span color=\"#3498db\">* <b>$(fr.name)</b> $message_escaped</span>");
    });

    fr.bind_property ("connected", entry, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("connected", send, "sensitive", BindingFlags.DEFAULT);
    fr.bind_property ("typing", friend_typing, "reveal_child", BindingFlags.DEFAULT);
    fr.bind_property ("name", username, "label", BindingFlags.DEFAULT);
    fr.bind_property ("status-message", status_message, "label", BindingFlags.DEFAULT);
  }

  private void add_row (string markup) {
    var label = new Gtk.Label (null);
    label.use_markup = true;
    label.set_markup (markup);
    label.halign = Gtk.Align.START;
    label.set_line_wrap (true);
    messages.append (label);
  }

  private void send_message () {
    var user = this.handle.username;
    string markup;

    var message = this.entry.get_text ();

    if (message.strip () == "")
      return;

    if (message.has_prefix ("/me ")) {
      var action = message.substring (4);
      var escaped = Util.escape_html (action);
      markup = @"<span color=\"#3498db\">* <b>$user</b> $escaped</span>";
      fr.send_action (action);
    } else if (message[0] == '>') {
      markup = @"<b>$user:</b> $(Util.add_markup (message))";
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
