[GtkTemplate (ui="/chat/tox/ricin/ui/message-list-row.ui")]
class Ricin.MessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Label label_message;
  [GtkChild] Gtk.Label label_timestamp;

  public MessageListRow (string name, string message, string timestamp) {
    /*this.label_name.set_text ("SkyzohKey");
    this.label_message.set_text ("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.");
    this.label_timestamp.set_text ("03:38:10");*/

    //if (name.strip () != "" && message.strip () != "" && timestamp != "") {}
    this.label_name.set_markup (@"<b>$name</b>");
    this.label_message.set_markup (message);
    this.label_timestamp.set_text (timestamp);
  }
}
