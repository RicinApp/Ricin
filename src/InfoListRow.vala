[GtkTemplate (ui="/chat/tox/ricin/ui/info-list-row.ui")]
class Ricin.InfoListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Image image_icon_info;
  [GtkChild] Gtk.Label label_message;

  public string message { get; set; default = ""; }

  public InfoListRow (string message) {
    this.message = message;
  
    this.init_widgets ();
    this.init_signals ();
  }
  
  private void init_widgets () {
    if (Settings.instance.compact_mode) {
      this.image_icon_info.set_size_request (-1, 20);
    } else {
      this.image_icon_info.set_size_request (80, 20);
    }
    
    this.label_message.set_markup (Util.render_emojis (this.message));
  }
  
  private void init_signals () {
    Settings.instance.notify["compact-mode"].connect (() => {
      if (Settings.instance.compact_mode) {
        this.image_icon_info.set_size_request (-1, 20);
      } else {
        this.image_icon_info.set_size_request (80, 20);
      }
    });
  }
}
