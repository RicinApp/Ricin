[GtkTemplate (ui="/chat/tox/ricin/ui/plain-label.ui")]
class Ricin.PlainLabel : Gtk.ListBoxRow {
  [GtkChild] public Gtk.Label label_text;

  public PlainLabel (string label) {
    this.label_text.set_markup (label);
    this.label_text.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
    this.label_text.set_justify (Gtk.Justification.FILL);
    this.label_text.activate_link.connect (this.handle_links);
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
