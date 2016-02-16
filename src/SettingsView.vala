[GtkTemplate (ui="/chat/tox/ricin/ui/settings-view.ui")]
class Ricin.SettingsView : Gtk.Notebook {
  // General settings tab.
  [GtkChild] Gtk.Label label_tox_id;
  [GtkChild] Gtk.Label label_toxme_alias;
  [GtkChild] Gtk.ComboBoxText combobox_toxme_servers;
  [GtkChild] Gtk.ComboBoxText combobox_languages;

  [GtkChild] Gtk.Switch switch_custom_themes;
  [GtkChild] Gtk.ComboBoxText combobox_selected_theme;
  [GtkChild] Gtk.Button button_reload_theme;

  [GtkChild] Gtk.Switch switch_status_changes;

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

    this.combobox_languages.append_text      ("English (default)");
    this.combobox_languages.append_text      ("Français");

    this.combobox_toxme_servers.append_text  ("Ricin.im (stable)");
    this.combobox_toxme_servers.append_text  ("ToxMe.io (stable)");
    this.combobox_toxme_servers.append_text  ("uTox.org (stable)");
    // this.combobox_toxme_servers.append ("toxing.me", "Toxing.me (unstable)");

    this.combobox_selected_theme.append_text ("Dark theme (Default)");
    this.combobox_selected_theme.append_text ("White theme");
    this.combobox_selected_theme.append_text ("Clearer theme");

    this.combobox_languages.active      = 0;
    this.combobox_toxme_servers.active  = 0;
    this.combobox_selected_theme.active = 0;

    /*this.combobox_languages.set_active_id       ("english");
    this.combobox_toxme_servers.set_active_id   ("ricin.im");
    this.combobox_selected_theme.set_active_id  ("default");*/

    this.switch_custom_themes.notify["active"].connect (() => {
      if (this.switch_custom_themes.active) {
        this.combobox_selected_theme.sensitive = true;
        int active = this.combobox_selected_theme.active;

        switch (active) {
          case 0:
            ThemeManager.instance.set_theme ("dark");
            break;
          case 1:
            ThemeManager.instance.set_theme ("white");
            break;
          case 2:
            ThemeManager.instance.set_theme ("clearer");
            break;
        }
      } else {
        this.combobox_selected_theme.sensitive = false;
        ThemeManager.instance.set_system_theme ();
      }
    });

    this.combobox_selected_theme.changed.connect (() => {
      int active = this.combobox_selected_theme.active;
      string title = this.combobox_selected_theme.get_active_text ();

      switch (active) {
        case 0:
          ThemeManager.instance.set_theme ("dark");
          break;
        case 1:
          ThemeManager.instance.set_theme ("white");
          break;
        case 2:
          ThemeManager.instance.set_theme ("clearer");
          break;
      }
    });

    this.button_reload_theme.clicked.connect (() => {
      ThemeManager.instance.reload_theme ();
    });

    /**
    * TODO:
    **/
    /*
      this.switch_udp_enabled.state_set.connect (this.udp_state_changed);
      this.switch_ipv6_enabled.state_set.connect (this.ipv6_state_changed);
      this.switch_proxy_enabled.state_set.connect (this.proxy_state_changed);
    */
  }

  /**
  * ToxID section.
  **/
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

  /**
  * ToxMe registration section.
  **/
  [GtkCallback]
  private void copy_toxme_alias () {
    string toxme_alias = this.label_toxme_alias.label;

    Gtk.Clipboard
    .get (Gdk.SELECTION_CLIPBOARD)
    .set_text (toxme_alias, -1);

    debug (@"ToxMe alias: $toxme_alias");
  }
}
