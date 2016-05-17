[GtkTemplate (ui="/chat/tox/ricin/ui/profile-chooser-window.ui")]
class Ricin.ProfileChooser : Gtk.ApplicationWindow {
  [GtkChild] Gtk.Notebook notebook_switcher;

  // Login (load profile).
  [GtkChild] Gtk.Label label_select_profile;
  [GtkChild] Gtk.ComboBoxText combobox_profiles;
  [GtkChild] Gtk.Entry entry_login_password;
  [GtkChild] Gtk.Button button_login;

  // Register (create then load profile).
  [GtkChild] Gtk.Label label_create_profile;
  [GtkChild] Gtk.Entry entry_register_name;
  [GtkChild] Gtk.Entry entry_register_password;
  [GtkChild] Gtk.Button button_register;

  private Settings settings;

  public ProfileChooser (Gtk.Application app) {
    Object (application: app);
    this.settings = Settings.instance;

    Gdk.Pixbuf app_icon = new Gdk.Pixbuf.from_resource (Ricin.ICON_PATH);
    this.window_position = Gtk.WindowPosition.CENTER;
    this.set_title (Ricin.APP_NAME + " - " + _("Select a profile"));
    this.set_icon (app_icon);
    this.set_default_size (261, 150);
    this.set_resizable (false);

    this.populate_profiles ();
    this.show_all ();
  }

  private void populate_profiles () {
    int latest_index = 0;
    string last_profile_used = this.settings.last_profile;

    var dir = File.new_for_path (Tox.profile_dir ());
    string[] profiles = {};
    if (!dir.query_exists ()) {
      dir.make_directory ();
    } else {
      var enumerator = dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);
      FileInfo info;
      int i = 0;
      while ((info = enumerator.next_file ()) != null) {
        var pname = info.get_name ();
        if (pname.has_suffix (".tox")) {
          profiles += pname;
          if (pname.replace (".tox", "") == last_profile_used) {
            latest_index = i;
          }
          i++;
        }
      }
    }

    foreach (string profile in profiles) {
      this.combobox_profiles.append_text (profile);
    }
    this.combobox_profiles.active = latest_index;

    if (profiles.length == 0) {
      // Set the tabpage as create page.
      this.notebook_switcher.page = 1;
    }
  }

  [GtkCallback]
  private void login () {
    var pname = this.combobox_profiles.get_active_text ();
    var pass = this.entry_login_password.get_text ();
    var profile = Tox.profile_dir () + pname;

    if (FileUtils.test (profile, FileTest.EXISTS)) {
      this.button_login.sensitive = false;
      this.settings.last_profile = pname.replace (".tox", "");
      new MainWindow (this.application, profile, pass);
      this.close (); // if a dialog is open, the window will not be closed
      this.button_login.sensitive = true;
    } else {
      // file deleted?
      this.button_login.sensitive = true;
      this.label_select_profile.set_markup ("<span color=\"#e74c3c\">" + _("The selected profile doesn't exists.") + "</span>");
    }
  }

  [GtkCallback]
  private void register () {
    var entry = this.entry_register_name.get_text ();
    var pass = this.entry_register_password.get_text ();

    if (entry.strip () == "") {
      this.label_create_profile.set_markup ("<span color=\"#e74c3c\">" + _("Please enter a profile name.") + "</span>");
      return;
    }

    var profile = Tox.profile_dir () + entry.replace (" ", "-") + ".tox";

    if (FileUtils.test (profile, FileTest.EXISTS)) {
      this.label_create_profile.set_markup ("<span color=\"#e74c3c\">" + _("Profile name already taken.") + "</span>");
    } else {
      this.entry_register_name.sensitive = false; // To prevent issue.
      this.button_register.sensitive = false; // To prevent issue.
      new MainWindow (this.application, profile, pass, true);
      this.button_register.sensitive = true;
      this.populate_profiles ();
      this.close ();
    }
  }

  [GtkCallback]
  private void reset_warning_label () {
    var label = this.label_create_profile.get_text ();
    var label_default = _("Choose a name for the profile");
    if (label != label_default) {
      this.label_create_profile.set_text (label_default);
    }
  }
}
