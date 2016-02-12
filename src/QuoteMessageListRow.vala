[GtkTemplate (ui="/chat/tox/ricin/ui/quote-message-list-row.ui")]
class Ricin.QuoteMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.ListBox listbox_quotes;
  [GtkChild] Gtk.Label label_timestamp;

  private uint position;
  private weak Tox.Tox handle;

  public QuoteMessageListRow (Tox.Tox handle, string name, string message, string timestamp) {
    this.handle = handle;


    string[] lines = message.split ("\n");
    foreach (string line in lines) {
      if (line.index_of ("&gt;", 0) == 0 && line != "&gt;") {
        this.listbox_quotes.add (new QuoteLabel (line.splice (0, 4)));
      } else {
        this.listbox_quotes.add (new PlainLabel (line));
      }
    }

    this.label_name.set_markup (@"<b>$name</b>");
    this.label_timestamp.set_text (timestamp);

    //this.label_quote.activate_link.connect (this.handle_links);
    //this.label_message.activate_link.connect (this.handle_links);

    /**
    * Keep the name in sync.
    */

    // If message is our (ugly&hacky way).
    if (this.handle.username == name) {
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
    }
  }

  private bool handle_links (string uri) {
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
  }
}
