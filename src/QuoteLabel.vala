[GtkTemplate (ui="/chat/tox/ricin/ui/quote-label.ui")]
class Ricin.QuoteLabel : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_quote;

  public QuoteLabel (string label) {
    this.label_quote.set_markup (label);
    this.label_quote.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
    this.label_quote.set_justify (Gtk.Justification.FILL);
    this.label_quote.activate_link.connect (this.handle_links);
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
      var info_message = _("ToxDNS is not supported yet.");
      main_window.notify_message (@"<span color=\"#e74c3c\">$info_message</span>");
    }

    return true;
  }
}
