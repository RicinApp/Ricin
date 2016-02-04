[GtkTemplate (ui="/chat/tox/ricin/ui/message-list-row.ui")]
class Ricin.MessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Label label_message;
  [GtkChild] Gtk.Label label_timestamp;

  private uint position;
  private weak Tox.Tox handle;

  public MessageListRow (Tox.Tox handle, string name, string message, string timestamp) {
    this.handle = handle;
    /*this.label_name.set_text ("SkyzohKey");
    this.label_message.set_text ("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.");
    this.label_timestamp.set_text ("03:38:10");*/

    //if (name.strip () != "" && message.strip () != "" && timestamp != "") {}

    /**
    * TEMP DEV ZONE:
    * EMOJI SUPPORT.
    **/
    var msg = message;
    /**
    * TEMP DEV ZONE:
    * EMOJI SUPPORT.
    **/

    this.label_name.set_markup (@"<b>$name</b>");
    this.label_message.set_markup (msg);
    this.label_timestamp.set_text (timestamp);

    this.label_message.activate_link.connect (this.handle_links);

    /**
    * Keep the name in sync.
    */

    // If message is our (ugly&hacky way).
    if (this.handle.username == name) {
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
    }
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
