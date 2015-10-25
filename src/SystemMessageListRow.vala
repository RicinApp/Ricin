[GtkTemplate (ui="/chat/tox/ricin/ui/system-message-list-row.ui")]
class Ricin.SystemMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_message;

  public SystemMessageListRow (string message) {
    this.label_message.set_text ("El SkyzohKey is now know as SkyzohKey");
  }
}
