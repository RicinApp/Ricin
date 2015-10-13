[GtkTemplate (ui="/chat/tox/Ricin/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
  [GtkChild] Gtk.ListBox messages_list;
  [GtkChild] Gtk.Entry entry;
  [GtkChild] Gtk.Button send;

  private ListStore messages = new ListStore (typeof (Gtk.Label));

  public Tox.Friend fr;

  public ChatView (Tox.Friend fr) {
    this.fr = fr;
    this.messages_list.bind_model (this.messages, l => l as Gtk.Widget);
    this.entry.placeholder_text = "Enter your message and press Enter...";

    this.init_signals ();
  }

  private void init_signals () {
    this.key_press_event.connect ((event) => {
      if (event.keyval == Gdk.Key.Return) {
        this.send_message ();
      }

      return false;
    });

    send.clicked.connect (() => {
      this.send_message ();
    });

    fr.message.connect (message => {
      var label = new Gtk.Label ("");
      label.halign = Gtk.Align.START;
      label.use_markup = true;
      label.set_markup (@"<b>$(fr.name):</b> $message");
      messages.append (label);
    });

    fr.action.connect (message => {
      var label = new Gtk.Label ("");
      label.halign = Gtk.Align.START;
      label.use_markup = true;

      label.set_markup (@"<span color=\"#3498db\">* <b>$(fr.name)</b> $message</span>");
      messages.append (label);
    });
  }

  private void send_message () {
    var message = this.entry.get_text ();
    var label = new Gtk.Label ("");
    label.halign = Gtk.Align.START;
    label.use_markup = true;

    messages.append (label);

    if (message.has_prefix ("/me ")) {
      message = message.splice(0, 4); // Removes the "/me " part.
      label.set_markup (@"<span color=\"#3498db\">* <b>Me</b> $message</span>");
      fr.send_action (message);
    } else {
      label.set_markup (@"<b>Me:</b> $message");
      fr.send_message (message);
    }

    // Clear and focus the entry.
    this.entry.text = "";
    this.entry.grab_focus_without_selecting ();
  }
}
