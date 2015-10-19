[GtkTemplate (ui="/chat/tox/ricin/ui/settings-view.ui")]
class Ricin.SettingsView : Gtk.Notebook {
  // General settings tab.
  [GtkChild] Gtk.Button button_toxid_copy;
  [GtkChild] Gtk.Button button_toxid_change_nospam;
  [GtkChild] Gtk.Label label_tox_id;
  [GtkChild] Gtk.ComboBoxText combobox_languages;

  // Network settings tab.
  [GtkChild] Gtk.Switch switch_udp_enabled;
  [GtkChild] Gtk.Switch switch_ipv6_enabled;
  [GtkChild] Gtk.Switch switch_proxy_enabled;
  [GtkChild] Gtk.Entry entry_proxy_ip;
  [GtkChild] Gtk.Entry entry_proxy_port;

  private weak Tox.Tox handle;
  private Gtk.Clipboard clipboard;

  public SettingsView (Tox.Tox handle) {
    this.handle = handle;
    this.label_tox_id.set_text (this.handle.id);
    this.clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);

    this.button_toxid_copy.clicked.connect (() => {
      this.clipboard.set_text (this.label_tox_id.get_text (), -1);
    });
  }
}
