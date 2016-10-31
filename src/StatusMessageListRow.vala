[GtkTemplate (ui="/chat/tox/ricin/ui/status-message-list-row.ui")]
class Ricin.StatusMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Image image_status;
  [GtkChild] Gtk.Label label_message;
  [GtkChild] Gtk.Label label_timestamp;
  private uint position;

  public StatusMessageListRow (string message, Tox.UserStatus status) {
    string icon = Util.status_to_icon (status, 0);
    
    if (Settings.instance.compact_mode) {
      this.label_name.visible = false;
      this.image_status.margin_left = 12; // Half compact image mode.
      this.label_message.margin_left = 16; // To correctly align the text with messages.
    } else {
      this.label_name.visible = true;
    }

    this.label_name.set_text ("");
    this.image_status.set_from_resource (@"/chat/tox/ricin/images/status/$icon.png");
    this.label_message.set_markup (message);
    this.label_timestamp.set_text (time ());
  }

  private string time () {
    return new DateTime.now_local ().format ("%H:%M:%S %p");
  }
}
