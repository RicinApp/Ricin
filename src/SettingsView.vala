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
  [GtkChild] Gtk.Label label_default_save_path;
  [GtkChild] Gtk.Entry entry_default_save_path;
  [GtkChild] Gtk.Button button_set_default_save_path;
  [GtkChild] Gtk.Button button_password_add;
  [GtkChild] Gtk.Button button_password_change;
  [GtkChild] Gtk.Button button_password_remove;

  // Interface settings tab;
  [GtkChild] Gtk.Switch switch_custom_themes;
  [GtkChild] Gtk.ComboBoxText combobox_selected_theme;
  [GtkChild] Gtk.Button button_reload_theme;

  [GtkChild] Gtk.Switch switch_status_changes;
  [GtkChild] Gtk.Switch switch_unread_messages;
  [GtkChild] Gtk.Switch switch_display_typing_notifications;
  [GtkChild] Gtk.Switch switch_typing_notifications;
  [GtkChild] Gtk.Switch switch_compact_friendlist;

  // Network settings tab.
  [GtkChild] Gtk.Switch switch_udp_enabled;
  [GtkChild] Gtk.Switch switch_ipv6_enabled;
  [GtkChild] Gtk.Switch switch_proxy_enabled;
  [GtkChild] Gtk.Entry entry_proxy_ip;
  [GtkChild] Gtk.SpinButton spinbutton_proxy_port;

  // About tab.
  [GtkChild] Gtk.Label label_app_description;
  [GtkChild] Gtk.Label label_app_version;

  private weak Tox.Tox handle;
  private Settings settings;

  public signal void reload_options ();

  public SettingsView (Tox.Tox handle) {
    this.handle = handle;
    this.settings = Settings.instance;

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
    this.label_app_description.set_markup (Ricin.APP_SUMMARY);
    this.label_app_version.set_text (_(Ricin.APP_VERSION));

    this.label_tox_id.set_text (handle.id);

    var default_str = _("default");
    var stable_str = _("stable");
    this.combobox_languages.append_text (@"English ($default_str)");
    this.combobox_languages.append_text ("Français");
    this.combobox_languages.append_text ("Portuguese");
    this.combobox_languages.append_text ("Danish");
    this.combobox_languages.append_text ("Esperanto");
    this.combobox_languages.append_text ("Chinese");
    this.combobox_languages.append_text ("German");
    this.combobox_languages.append_text ("Ukrainian");
    this.combobox_languages.append_text ("Russian");

    this.combobox_toxme_servers.append_text (@"Ricin.im ($default_str)");
    this.combobox_toxme_servers.append_text (@"ToxMe.io ($stable_str)");
    this.combobox_toxme_servers.append_text (@"uTox.org ($stable_str)");

    this.combobox_selected_theme.append_text (_("Dark theme") + @" ($default_str)");
    this.combobox_selected_theme.append_text (_("White theme"));
    this.combobox_selected_theme.append_text (_("Clearer theme"));

    this.combobox_languages.active      = 0;
    this.combobox_toxme_servers.active  = 0;

    this.handle.notify["encrypted"].connect (this.reset_profile_buttons);
    this.reset_profile_buttons ();

    string selected_language = this.settings.selected_language;
    if (selected_language == "en_US") {
      this.combobox_languages.active = 0;
    } else if (selected_language == "fr_FR") {
      this.combobox_languages.active = 1;
    } else if (selected_language == "pt_PT") {
      this.combobox_languages.active = 2;
    } else if (selected_language == "da_DK") {
      this.combobox_languages.active = 3;
    } else if (selected_language == "eo") {
      this.combobox_languages.active = 4;
    } else if (selected_language == "zh_CN") {
      this.combobox_languages.active = 5;
    } else if (selected_language == "de") {
      this.combobox_languages.active = 6;
    } else if (selected_language == "uk") {
      this.combobox_languages.active = 7;
    } else if (selected_language == "ru_RU") {
      this.combobox_languages.active = 8;
    }

    this.combobox_languages.changed.connect (() => {
      var slang = this.combobox_languages.active;

      if (slang == 0) { // English.
        info ("Changed locale to English.");
        Environment.set_variable ("LANG", "en_US", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "en_US");
        this.settings.selected_language = "en_US";
      } else if (slang == 1) { // French
        info ("Changed locale to French.");
        Environment.set_variable ("LANG", "fr_FR", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "fr_FR");
        this.settings.selected_language = "fr_FR";
      } else if (slang == 2) { // Portuguese
        info ("Changed locale to Portuguese.");
        Environment.set_variable ("LANG", "pt_PT", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "pt_PT");
        this.settings.selected_language = "pt_PT";
      } else if (slang == 3) { // Danish
        info ("Changed locale to Danish.");
        Environment.set_variable ("LANG", "da_DK", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "da_DK");
        this.settings.selected_language = "da_DK";
      } else if (slang == 4) { // Esperanto
        info ("Changed locale to Esperanto.");
        Environment.set_variable ("LANG", "eo", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "eo");
        this.settings.selected_language = "eo";
      } else if (slang == 5) { // Chinese
        info ("Changed locale to Chinese.");
        Environment.set_variable ("LANG", "zh_CN", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "zh_CN");
        this.settings.selected_language = "zh_CN";
      } else if (slang == 6) { // German
        info ("Changed locale to German.");
        Environment.set_variable ("LANG", "de", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "de");
        this.settings.selected_language = "de";
      } else if (slang == 7) { // Ukrainian
        info ("Changed locale to Ukrainian.");
        Environment.set_variable ("LANG", "uk", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "uk");
        this.settings.selected_language = "uk";
      } else if (slang == 8) { // Russian
        info ("Changed locale to Russian.");
        Environment.set_variable ("LANG", "ru_RU", true);
        Intl.setlocale (LocaleCategory.MESSAGES, "ru_RU");
        this.settings.selected_language = "ru_RU";
      }

      this.reload_options ();
    });

    string selected_theme = this.settings.selected_theme;
    if (selected_theme == "dark") {
      this.combobox_selected_theme.active = 0;
    } else if (selected_theme == "white") {
      this.combobox_selected_theme.active = 1;
    } else {
      this.combobox_selected_theme.active = 2;
    }

    bool enable_custom_themes = this.settings.enable_custom_themes;
    this.switch_custom_themes.active = enable_custom_themes;
    this.combobox_selected_theme.sensitive = enable_custom_themes;
    this.button_reload_theme.sensitive = enable_custom_themes;
    this.switch_status_changes.active = this.settings.show_status_changes;

    this.switch_custom_themes.notify["active"].connect (() => {
      if (this.switch_custom_themes.active) {
        this.combobox_selected_theme.sensitive = true;
        this.button_reload_theme.sensitive = true;
        int active = this.combobox_selected_theme.active;

        switch (active) {
          case 0:
            ThemeManager.instance.set_theme ("dark");
            this.settings.selected_theme = "dark";
            break;
          case 1:
            ThemeManager.instance.set_theme ("white");
            this.settings.selected_theme = "white";
            break;
          case 2:
            ThemeManager.instance.set_theme ("clearer");
            this.settings.selected_theme = "clearer";
            break;
        }

        this.settings.enable_custom_themes = true;
      } else {
        this.combobox_selected_theme.sensitive = false;
        this.button_reload_theme.sensitive = false;
        ThemeManager.instance.set_system_theme ();
        this.settings.enable_custom_themes = false;
      }
    });

    this.combobox_selected_theme.changed.connect (() => {
      int active = this.combobox_selected_theme.active;
      string title = this.combobox_selected_theme.get_active_text ();

      switch (active) {
        case 0:
          ThemeManager.instance.set_theme ("dark");
          this.settings.selected_theme = "dark";
          break;
        case 1:
          ThemeManager.instance.set_theme ("white");
          this.settings.selected_theme = "white";
          break;
        case 2:
          ThemeManager.instance.set_theme ("clearer");
          this.settings.selected_theme = "clearer";
          break;
      }
    });

    this.button_reload_theme.clicked.connect (() => {
      ThemeManager.instance.reload_theme ();
    });

    this.entry_default_save_path.set_text (this.settings.default_save_path);

    this.switch_status_changes.notify["active"].connect (() => {
      this.settings.show_status_changes = this.switch_status_changes.active;
    });

    // Show typing notifications.
    this.switch_display_typing_notifications.active = this.settings.show_typing_status;
    this.switch_display_typing_notifications.notify["active"].connect (() => {
      this.settings.show_typing_status = this.switch_display_typing_notifications.active;
    });

    // Send typing notifications.
    this.switch_typing_notifications.active = this.settings.send_typing_status;
    this.switch_typing_notifications.notify["active"].connect (() => {
      this.settings.send_typing_status = this.switch_typing_notifications.active;
    });

    // Show unread messages notice.
    this.switch_unread_messages.active = this.settings.show_unread_messages;
    this.switch_unread_messages.notify["active"].connect (() => {
      this.settings.show_unread_messages = this.switch_unread_messages.active;
    });

    // Switch compact mode.
    this.switch_compact_friendlist.active = this.settings.compact_mode;
    this.switch_compact_friendlist.notify["active"].connect (() => {
      this.settings.compact_mode = this.switch_compact_friendlist.active;
    });

    var udp = this.settings.network_udp;
    var ipv6 = this.settings.network_ipv6;
    var proxy = this.settings.enable_proxy;
    var proxy_host = this.settings.proxy_host;
    var proxy_port = (double) this.settings.proxy_port;
    this.switch_udp_enabled.set_active (udp);
    this.switch_ipv6_enabled.set_active (ipv6);
    this.switch_proxy_enabled.set_active (proxy);
    this.entry_proxy_ip.set_text (proxy_host);
    this.spinbutton_proxy_port.set_range (0, 65535); // Min, max values.
    this.spinbutton_proxy_port.value = proxy_port;

    this.switch_udp_enabled.notify["active"].connect (this.udp_state_changed);
    this.switch_ipv6_enabled.notify["active"].connect (this.ipv6_state_changed);
    this.switch_proxy_enabled.notify["active"].connect (this.proxy_state_changed);
  }

  private void udp_state_changed () {
    this.settings.network_udp = this.switch_udp_enabled.active;
    this.reload_options ();
  }

  private void ipv6_state_changed () {
    this.settings.network_ipv6 = this.switch_ipv6_enabled.active;
    this.reload_options ();
  }

  private void proxy_state_changed () {
    bool proxy_enabled = this.switch_proxy_enabled.active;
    string ip = this.entry_proxy_ip.get_text ();
    int port  = (int) this.spinbutton_proxy_port.value;

    this.settings.enable_proxy = proxy_enabled;
    this.settings.proxy_host = ip;
    this.settings.proxy_port = port;
    this.reload_options ();
  }

  private void reset_profile_buttons () {
    if (this.handle.encrypted) {
      this.button_password_add.sensitive    = false;
      this.button_password_change.sensitive = true;
      this.button_password_remove.sensitive = true;
    } else {
      this.button_password_add.sensitive    = true;
      this.button_password_change.sensitive = false;
      this.button_password_remove.sensitive = false;
    }
  }

  private bool show_dialog (string title, string message) {
    var main_window = this.get_toplevel () as MainWindow;
    var dialog = new Gtk.MessageDialog (
      main_window,
      Gtk.DialogFlags.MODAL,
      Gtk.MessageType.WARNING,
      Gtk.ButtonsType.NONE,
      title
    );

    dialog.secondary_use_markup = true;
    dialog.format_secondary_markup (message);
    dialog.add_buttons (
      _("Yes"), Gtk.ResponseType.ACCEPT,
      _("No"), Gtk.ResponseType.REJECT
    );

    uint response_id = dialog.run ();
    dialog.destroy();

    if (response_id == Gtk.ResponseType.ACCEPT) {
      return true;
    }

    return false;
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

  /**
  * Select default save path section.
  **/
  [GtkCallback]
  private void  select_save_path () {
    var main_window = this.get_toplevel () as MainWindow;
    var chooser = new Gtk.FileChooserDialog (
      _("Choose a folder where to save files"),
      main_window,
      Gtk.FileChooserAction.SELECT_FOLDER,
      _("_Cancel"), Gtk.ResponseType.CANCEL,
      _("_Open"), Gtk.ResponseType.ACCEPT
    );
    chooser.set_current_folder (this.settings.default_save_path);

    if (chooser.run () == Gtk.ResponseType.ACCEPT) {
      var path = chooser.get_current_folder ();
      this.settings.default_save_path = path;
      this.entry_default_save_path.set_text (path);
      debug (@"Default save path set to $path");
    }
    chooser.close ();
  }

  /**
  * Add a password to the currently opened profile.
  **/
  [GtkCallback]
  private void add_password () {
    debug ("Add Password triggered.");
    PasswordDialog dialog = new PasswordDialog (
      this.get_toplevel () as MainWindow,
      _("Encrypt your profile"),
      _("In order to encrypt your profile you need to specify a password. This password will be asked each time you login.") + "\n<b>" + _("Do you want to proceed anyway?") + "</b>",
      PasswordDialogType.ADD_PASSWORD
    );

    dialog.resp.connect ((response_id, password) => {
      if (response_id == Gtk.ResponseType.ACCEPT) {
        if (this.handle.add_password (password)) {
          Timeout.add (2000, () => { // Time to write to disk.
            this.reset_profile_buttons ();
            return Source.REMOVE;
          });
        }
      }
      dialog.destroy ();
    });

    dialog.show ();
  }

  /**
  * Change the password of the currently opened profile.
  **/
  [GtkCallback]
  private void change_password () {
    debug ("Change Password triggered.");
    PasswordDialog dialog = new PasswordDialog (
      this.get_toplevel () as MainWindow,
      _("Edit your password"),
      _("Changing your password will cause Ricin to decrypt your profile then re-encrypt it with the new password.") + "\n<b>" + _("Do you want to proceed anyway?") + "</b>",
      PasswordDialogType.EDIT_PASSWORD
    );

    dialog.resp.connect ((response_id, password, old_password) => {
      if (response_id == Gtk.ResponseType.ACCEPT) {
        if (this.handle.change_password (password, old_password)) {
          this.reset_profile_buttons ();
        }
      }
      dialog.destroy ();
    });

    dialog.show ();
  }

  /**
  * Remove the password from the currently opened profile.
  **/
  [GtkCallback]
  private void remove_password () {
    debug ("Remove Password triggered.");
    PasswordDialog dialog = new PasswordDialog (
      this.get_toplevel () as MainWindow,
      _("Unencrypt your profile"),
      _("Removing your password will unencrypt your profile, chat logs and settings.") + "\n<b>" + _("Do you want to proceed anyway?") + "</b>",
      PasswordDialogType.REMOVE_PASSWORD
    );

    dialog.resp.connect ((response_id, password) => {
      if (response_id == Gtk.ResponseType.ACCEPT) {
        print (@"Password: $password.\n");
        if (this.handle.remove_password (password)) {
          this.reset_profile_buttons ();
        }
      }
      dialog.destroy ();
    });

    dialog.show ();
  }
}
