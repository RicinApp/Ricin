[GtkTemplate (ui="/chat/tox/ricin/ui/group-list-row.ui")]
public class Ricin.GroupListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Image image_avatar;
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Button button_mute;
  [GtkChild] Gtk.Image image_mute;
  
  public weak Tox.Peer peer;
  
  public GroupListRow (Tox.Peer peer) {
    this.peer = peer;

    this.init_widgets ();
    this.init_signals ();
  }

  private void init_widgets () {
    this.image_avatar.pixbuf = Util.pubkey_to_image (this.peer.pubkey, 24, 24);
    
    this.label_name.set_text (this.peer.name);
    this.label_name.set_tooltip_text (this.peer.pubkey);
  }

  private void init_signals () {
    this.peer.name_changed.connect (() => {
      this.init_widgets ();
    });
  }

  [GtkCallback]
  private void mute_peer () {
    this.peer.muted = !this.peer.muted;
    
    if (this.peer.muted) {
      this.button_mute.set_tooltip_text (_("Unmute peer"));
      this.image_mute.icon_name = "notifications-disabled-symbolic";
    } else {
      this.button_mute.set_tooltip_text (_("Mute peer"));
      this.image_mute.icon_name = "notifications-symbolic";
    }
  }
}
