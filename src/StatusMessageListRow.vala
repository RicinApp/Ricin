[GtkTemplate (ui="/chat/tox/ricin/ui/status-message-list-row.ui")]
class Ricin.StatusMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_message;
  [GtkChild] Gtk.Image image_status;
  private uint position;

  public StatusMessageListRow (string message, Tox.UserStatus status) {
    this.label_message.set_markup ("<span color=\"#2a92c6\">" + message + "</span>");

    string icon = Util.status_to_icon (status, 0);
    this.image_status.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
  }
}
