[GtkTemplate (ui="/chat/tox/ricin/ui/quote-message-list-row.ui")]
class Ricin.QuoteMessageListRow : Gtk.ListBoxRow {
  [GtkChild] public Gtk.Label label_name;
  [GtkChild] Gtk.ListBox listbox_quotes;
  [GtkChild] Gtk.Spinner spinner_read;
  [GtkChild] Gtk.Label label_timestamp;

  private uint position;
  private uint32 message_id;
  public bool is_child = false;

  private weak Tox.Tox handle;
  private weak Tox.Friend sender;

  public QuoteMessageListRow (Tox.Tox handle, Tox.Friend? sender, string message, string timestamp, uint32 message_id, bool is_child) {
    this.handle = handle;
    this.message_id = message_id;
    this.sender = sender;
    this.is_child = is_child;
    string name = Util.escape_html (this.sender.name);

    if (this.sender == null) {
      this.label_name.set_markup ("<b>" + name + "</b>");

      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
      this.handle.message_read.connect ((friend_num, message_id) => {
        if (message_id != this.message_id) {
          return;
        }

        this.spinner_read.visible = false;
      });
    } else {
      this.label_name.set_text (name);
      this.spinner_read.visible = false;
    }

    if (this.is_child) {
      // Don't display name for childs.
      this.label_name.set_text ("");
    }

    this.label_timestamp.set_text (timestamp);

    string[] lines = message.split ("\n");
    foreach (string line in lines) {
      if (line.index_of ("&gt;", 0) == 0) {
        this.listbox_quotes.add (new QuoteLabel (line.splice (0, 4)));
      } else {
        this.listbox_quotes.add (new PlainLabel (line));
      }
    }

    //string[] quotes = lines.index_of ("&gt;", 0);
    //var line_text = line.splice (0, 4);
    //this.listbox_quotes.add (new QuoteLabel (message));

    /**
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
