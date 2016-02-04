[GtkTemplate (ui="/chat/tox/ricin/ui/system-message-list-row.ui")]
class Ricin.SystemMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_message;
  private uint position;

  public SystemMessageListRow (string message) {
    this.label_message.set_markup ("<span color=\"#2a92c6\">" + message + "</span>");
  }
}
