[GtkTemplate (ui="/chat/tox/ricin/ui/quote-message-list-row.ui")]
class Ricin.QuoteMessageListRow : Gtk.ListBoxRow {
  [GtkChild] public Gtk.Image image_author;
  [GtkChild] public Gtk.Label label_name;
  [GtkChild] Gtk.ListBox listbox_quotes;

  [GtkChild] public Gtk.Stack stack;
  [GtkChild] Gtk.Spinner spinner_read;
  [GtkChild] Gtk.Label label_timestamp;

  public string author { get; set; default = ""; }

  private uint position;
  private uint32 message_id;
  public bool is_child = false;

  private weak Tox.Tox handle;
  private weak Tox.Friend sender;
  private Settings settings;

  public QuoteMessageListRow (Tox.Tox handle, Tox.Friend? sender, string message, string timestamp, uint32 message_id, bool is_child) {
    this.handle = handle;
    this.message_id = message_id;
    this.sender = sender;
    this.is_child = is_child;
    this.settings = Settings.instance;

    this.stack.set_visible_child_name ("spinner");
    this.image_author.set_from_pixbuf (Util.pubkey_to_image (this.sender.pubkey, 24, 24));
    this.sender.avatar.connect (p => {
      this.image_author.pixbuf = p;
    });

    string name;

    if (this.settings.compact_mode) {
      this.label_name.visible = false;
      this.image_author.visible = true;
    } else {
      this.label_name.visible = true;
      this.image_author.visible = false;
    }
    this.settings.notify["compact-mode"].connect (() => {
      if (this.settings.compact_mode) {
        this.label_name.visible = false;
        this.image_author.visible = true;
      } else {
        this.label_name.visible = true;
        this.image_author.visible = false;
      }
    });

    if (this.sender == null) {
      this.image_author.set_from_pixbuf (Util.pubkey_to_image (this.handle.pubkey, 24, 24));
      this.image_author.pixbuf = this.image_author.pixbuf.scale_simple (24, 24, Gdk.InterpType.BILINEAR);
      this.image_author.set_pixel_size (24);
      this.image_author.set_size_request (24, 24);

      this.handle.notify["avatar"].connect (() => {
        this.image_author.pixbuf = this.handle.avatar.scale_simple (24, 24, Gdk.InterpType.BILINEAR);;
      });

      this.image_author.set_tooltip_text (this.handle.username);
      this.handle.notify["username"].connect (() => {
        this.image_author.set_tooltip_text (this.handle.username);
      });

      name = Util.escape_html (this.handle.username);
      this.label_name.set_markup ("<b>" + name + "</b>");
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);

      this.handle.message_read.connect ((friend_num, message_id) => {
        if (message_id != this.message_id) {
          return;
        }

        this.stack.set_visible_child_name ("timestamp");
      });
    } else {
      this.image_author.set_from_pixbuf (Util.pubkey_to_image (this.sender.pubkey, 24, 24));
      this.image_author.pixbuf = this.image_author.pixbuf.scale_simple (24, 24, Gdk.InterpType.BILINEAR);
      this.image_author.set_pixel_size (24);
      this.image_author.set_size_request (24, 24);

      this.image_author.set_tooltip_text (this.sender.name);
      this.sender.avatar.connect (p => {
        this.image_author.pixbuf = p.scale_simple (24, 24, Gdk.InterpType.BILINEAR);;
      });

      name = Util.escape_html (this.sender.get_uname ());
      this.label_name.set_text (name);

      this.stack.set_visible_child_name ("timestamp");
    }

    this.author = name;

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
  }

  public string get_quote () {
    StringBuilder sb = new StringBuilder ();
    foreach (Gtk.Widget item in this.listbox_quotes.get_children ()) {
      var txt = "";

      if (item is QuoteLabel) {
        txt = ((QuoteLabel) item).label_quote.get_text ();
      } else if (item is PlainLabel) {
        txt = ((PlainLabel) item).label_text.get_text ();
      }

      string[] lines = txt.split ("\n");
      foreach (string line in lines) {
        txt = ">" + line;
      }

      sb.append (txt);
      sb.append_c ('\n');
    }

    sb.truncate (sb.len - 1);
    return (string) sb.data;
  }

  private bool handle_links (string uri) {
    if (!uri.has_prefix ("tox:")) {
      return false; // Default behavior.
    }

    var main_window = ((MainWindow) this.get_toplevel ());
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
