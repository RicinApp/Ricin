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
    this.label_name.set_markup (@"<b>$name</b>");
    this.label_timestamp.set_text (timestamp);

    //this.label_quote.activate_link.connect (this.handle_links);
    //this.label_message.activate_link.connect (this.handle_links);

    // If message is our (ugly&hacky way).
    if (this.handle.username == name) {
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
    }

    if (lines.length == 1) {
      var line_text = lines[0];
      this.listbox_quotes.add (new QuoteLabel (((string) line_text.data).splice (0, 4)));

      return;
    }

    var last_line_type = "plain";
    var line_count = 0;
    StringBuilder tmp_quote = new StringBuilder ();
    StringBuilder tmp_plain = new StringBuilder ();

    foreach (string line in lines) {
      var line_type = (line.index_of ("&gt;", 0) == 0) ? "quote" : "plain";
      var line_text = line.splice (0, 4);

      if (line_count == 0) {
        // Fix an issue with trailing \n.
        last_line_type = line_type;
      }

      if (last_line_type != line_type) {
        if (line_type == "quote") {
          // Add a Plain label then clean the tmp_plain sb.
          tmp_plain.truncate (tmp_plain.len - 1);
          this.listbox_quotes.add (new PlainLabel ((string) tmp_plain.data));
          tmp_plain = new StringBuilder ();
        } else if (line_type == "plain") {
          // Add a Quote label then clean the tmp_quote sb.
          tmp_quote.truncate (tmp_quote.len - 1);
          this.listbox_quotes.add (new QuoteLabel ((string) tmp_quote.data));
          tmp_quote = new StringBuilder ();
        }
      }

      if (line_type == "quote") {
        // Add the current line in tmp_quote.
        tmp_quote.append (line_text);
        tmp_quote.append_c ('\n');
      } else if (line_type == "plain") {
        // Add the current line in tmp_plain.
        tmp_plain.append (line);
        tmp_plain.append_c ('\n');
      }

      last_line_type = line_type;
      line_count++;
    }

      /*
      if (line.index_of ("&gt;", 0) == 0 && line != "&gt;") {
        this.listbox_quotes.add (new QuoteLabel (line.splice (0, 4)));
        last_line_type = "quote";
      } else {
        this.listbox_quotes.add (new PlainLabel (line));
        last_line_type = "plain";
      }
      */
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
