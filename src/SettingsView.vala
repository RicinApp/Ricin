[GtkTemplate (ui="/chat/tox/ricin/ui/settings-view.ui")]
class Ricin.SettingsView : Gtk.Box {
  // Notebook buttons
  [GtkChild] Gtk.Box box_tab_buttons;
  [GtkChild] Gtk.Notebook notebook_settings;

  // General settings tab.
  [GtkChild] Gtk.Label label_tox_id;
  [GtkChild] Gtk.Label label_toxme_alias;
  [GtkChild] Gtk.ComboBoxText combobox_toxme_servers;
  [GtkChild] Gtk.ComboBoxText combobox_languages;

  // Interface settings tab;
  [GtkChild] Gtk.Switch switch_custom_themes;
  [GtkChild] Gtk.ComboBoxText combobox_selected_theme;
  [GtkChild] Gtk.Button button_reload_theme;

  [GtkChild] Gtk.Switch switch_status_changes;
  [GtkChild] Gtk.Switch switch_typing_notifications;

  /* TODO
  // Network settings tab.
  [GtkChild] Gtk.Switch switch_udp_enabled;
  [GtkChild] Gtk.Switch switch_ipv6_enabled;
  [GtkChild] Gtk.Switch switch_proxy_enabled;
  [GtkChild] Gtk.Entry entry_proxy_ip;
  [GtkChild] Gtk.Entry entry_proxy_port;
  */

  // About tab.
  [GtkChild] Gtk.Label label_app_name;
  [GtkChild] Gtk.Label label_app_description;
  [GtkChild] Gtk.Label label_app_version;

  private weak Tox.Tox handle;
  private SettingsManager settings;

  public SettingsView (Tox.Tox handle) {
    this.handle = handle;
    this.settings = SettingsManager.instance;

    /**
    * Pack buttons in the RicinSettingsView box.
    * This is a quick fix for the issue with tabpages.
    **/
    Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    box.set_homogeneous (true);

    var pages_number = this.notebook_settings.get_n_pages ();
    for (var i = 0; i < pages_number; i++) {
      var page_num = i;
      var page = this.notebook_settings.get_nth_page (i);
      var label = this.notebook_settings.get_tab_label_text (page);

      var btn = new Gtk.Button.with_mnemonic (label);
      btn.set_relief (Gtk.ReliefStyle.NONE);
      btn.clicked.connect (() => {
        this.notebook_settings.set_current_page (page_num);
      });

      box.pack_start (btn, true, true, 0);
    }

    this.box_tab_buttons.add (box);

    // About tab →
    this.label_app_name.set_text (Ricin.APP_NAME);
    this.label_app_description.set_markup (Ricin.APP_SUMMARY);
    this.label_app_version.set_text (Ricin.APP_VERSION);

    this.label_tox_id.set_text (handle.id);

    this.combobox_languages.append_text      ("English (default)");
    this.combobox_languages.append_text      ("Français");

    this.combobox_toxme_servers.append_text  ("Ricin.im (default)");
    this.combobox_toxme_servers.append_text  ("ToxMe.io (stable)");
    this.combobox_toxme_servers.append_text  ("uTox.org (stable)");
    // this.combobox_toxme_servers.append ("toxing.me", "Toxing.me (unstable)");

    this.combobox_selected_theme.append_text ("Dark theme (default)");
    this.combobox_selected_theme.append_text ("White theme");
    this.combobox_selected_theme.append_text ("Clearer theme");

    this.combobox_languages.active      = 0;
    this.combobox_toxme_servers.active  = 0;

    string selected_theme = this.settings.get_string ("ricin.interface.selected_theme");
    if (selected_theme == "dark") {
      this.combobox_selected_theme.active = 0;
    } else if (selected_theme == "white") {
      this.combobox_selected_theme.active = 1;
    } else {
      this.combobox_selected_theme.active = 2;
    }

    bool enable_custom_themes = this.settings.get_bool ("ricin.interface.enable_custom_themes");
    this.switch_custom_themes.active = enable_custom_themes;
    this.combobox_selected_theme.sensitive = enable_custom_themes;
    this.button_reload_theme.sensitive = enable_custom_themes;

    bool display_friends_status_changes = this.settings.get_bool ("ricin.interface.display_friends_status_changes");
    this.switch_status_changes.active = display_friends_status_changes;

    this.switch_custom_themes.notify["active"].connect (() => {
      if (this.switch_custom_themes.active) {
        this.combobox_selected_theme.sensitive = true;
        this.button_reload_theme.sensitive = true;
        int active = this.combobox_selected_theme.active;

        switch (active) {
          case 0:
            ThemeManager.instance.set_theme ("dark");
            this.settings.write_string ("ricin.interface.selected_theme", "dark");
            break;
          case 1:
            ThemeManager.instance.set_theme ("white");
            this.settings.write_string ("ricin.interface.selected_theme", "white");
            break;
          case 2:
            ThemeManager.instance.set_theme ("clearer");
            this.settings.write_string ("ricin.interface.selected_theme", "clearer");
            break;
        }

        this.settings.write_bool ("ricin.interface.enable_custom_themes", true);
      } else {
        this.combobox_selected_theme.sensitive = false;
        this.button_reload_theme.sensitive = false;
        ThemeManager.instance.set_system_theme ();
        this.settings.write_bool ("ricin.interface.enable_custom_themes", false);
      }
    });

    this.combobox_selected_theme.changed.connect (() => {
      int active = this.combobox_selected_theme.active;
      string title = this.combobox_selected_theme.get_active_text ();

      switch (active) {
        case 0:
          ThemeManager.instance.set_theme ("dark");
          this.settings.write_string ("ricin.interface.selected_theme", "dark");
          break;
        case 1:
          ThemeManager.instance.set_theme ("white");
          this.settings.write_string ("ricin.interface.selected_theme", "white");
          break;
        case 2:
          ThemeManager.instance.set_theme ("clearer");
          this.settings.write_string ("ricin.interface.selected_theme", "clearer");
          break;
      }
    });

    this.button_reload_theme.clicked.connect (() => {
      ThemeManager.instance.reload_theme ();
    });

    this.switch_status_changes.notify["active"].connect (() => {
      this.settings.write_bool (
        "ricin.interface.display_friends_status_changes",
        this.switch_status_changes.active
      );
    });

    // Send typing notifications.
    this.switch_typing_notifications.notify["active"].connect (() => {
      this.settings.write_bool (
        "ricin.interface.send_typing_notification",
        this.switch_typing_notifications.active
      );
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
