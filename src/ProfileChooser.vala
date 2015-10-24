[GtkTemplate (ui="/chat/tox/ricin/ui/profile-chooser-window.ui")]
class Ricin.ProfileChooser : Gtk.ApplicationWindow {
  [GtkChild] Gtk.Notebook notebook_switcher;

  // Login (load profile).
  [GtkChild] Gtk.Label label_select_profile;
  [GtkChild] Gtk.ComboBoxText combobox_profiles;
  [GtkChild] Gtk.Button button_login;

  // Register (create then load profile).
  [GtkChild] Gtk.Label label_create_profile;
  [GtkChild] Gtk.Entry entry_register_name;
  [GtkChild] Gtk.Button button_register;

  public ProfileChooser (Gtk.Application app) {
    Object (application: app);
    this.title = "Ricin - Select a profile";

    var dir = File.new_for_path (Tox.profile_dir ());
    string[] profiles = {};
    if (!dir.query_exists ()) {
      dir.make_directory ();
    } else {
      var enumerator = dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);
      FileInfo info;
      while ((info = enumerator.next_file ()) != null) {
        if (info.get_name ().has_suffix (".tox")) {
          profiles += info.get_name ();
        }
      }
    }

    foreach (string profile in profiles) {
      this.combobox_profiles.append_text (profile);
    }
    if (profiles.length == 0) {
      // Set the tabpage as create page.
      this.notebook_switcher.page = 1;
    }

    this.show_all ();
  }

  [GtkCallback]
  private void login () {
    var profile = Tox.profile_dir () + this.combobox_profiles.get_active_text ();

    if (FileUtils.test (profile, FileTest.EXISTS)) {
      new MainWindow (this.application, profile);
      this.close (); // if a dialog is open, the window will not be closed
    } else {
      // file deleted?
      this.label_select_profile.set_markup ("<span color=\"#e74c3c\">The selected profile doesn't exists.</span>");
    }
  }

  [GtkCallback]
  private void register () {
    var entry = this.entry_register_name.get_text ();

    if (entry.strip () == "") {
      this.label_create_profile.set_markup ("<span color=\"#e74c3c\">Please enter a profile name.</span>");
      return;
    }

    var profile = Tox.profile_dir () + entry.replace (" ", "-") + ".tox";

    if (FileUtils.test (profile, FileTest.EXISTS)) {
      this.label_create_profile.set_markup ("<span color=\"#e74c3c\">Profile name already taken.</span>");
    } else {
      this.entry_register_name.sensitive = false; // To prevent issue.
      this.button_register.sensitive = false; // To prevent issue.
      new MainWindow (this.application, profile);
      this.close ();
    }
  }

  [GtkCallback]
  private void reset_warning_label () {
    var label = this.label_create_profile.get_text ();
    var label_default = "Enter a name for the profile";
    if (label != label_default) {
      this.label_create_profile.set_text (label_default);
    }
  }
}
