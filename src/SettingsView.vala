[GtkTemplate (ui="/chat/tox/ricin/ui/settings-view.ui")]
class Ricin.SettingsView : Gtk.Notebook {
  // General settings tab.
  [GtkChild] Gtk.Label label_tox_id;
  [GtkChild] Gtk.ComboBoxText combobox_languages;

  /* TODO
  // Network settings tab.
  [GtkChild] Gtk.Switch switch_udp_enabled;
  [GtkChild] Gtk.Switch switch_ipv6_enabled;
  [GtkChild] Gtk.Switch switch_proxy_enabled;
  [GtkChild] Gtk.Entry entry_proxy_ip;
  [GtkChild] Gtk.Entry entry_proxy_port;
  */

  private weak Tox.Tox handle;

  public SettingsView (Tox.Tox handle) {
    this.handle = handle;
    this.label_tox_id.set_text (handle.id);

    this.combobox_languages.append ("english", "English (default)");
    this.combobox_languages.set_active_id ("english");

    /* TODO
    this.switch_udp_enabled.state_set.connect (this.udp_state_changed);
    this.switch_ipv6_enabled.state_set.connect (this.ipv6_state_changed);
    this.switch_proxy_enabled.state_set.connect (this.proxy_state_changed);
    */
  }

  [GtkCallback]
  private void copy_toxid () {
    Gtk.Clipboard
      .get (Gdk.SELECTION_CLIPBOARD)
      .set_text (this.label_tox_id.label, -1);
  }

  [GtkCallback]
  private void change_nospam () {
    this.handle.nospam = Random.next_int ();
    this.label_tox_id.label = this.handle.id; // Update the ToxID
  }
}
