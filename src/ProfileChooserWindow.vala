using Tox;
using ToxCore;

[GtkTemplate (ui="/chat/tox/Ricin/profile-chooser-window.ui")]
class Ricin.ProfileChooserWindow  : Gtk.Window {
  [GtkChild] Gtk.Notebook notebook_switcher;

  // Login (load profile).
  [GtkChild] Gtk.Label label_select_profile;
  [GtkChild] Gtk.ComboBoxText combobox_profiles;
  [GtkChild] Gtk.Button button_login;

  // Register (create then load profile).
  [GtkChild] Gtk.Label label_create_profile;
  [GtkChild] Gtk.Entry entry_register_name;
  [GtkChild] Gtk.Button button_register;

  private Ricin app;

  public ProfileChooserWindow (Ricin app) {
    this.app = app;
    this.title = "Ricin - Select a profile";

    this.destroy.connect (() => {
			debug ("Exited app from ProfileChooserWindow. Bye.");
			Gtk.main_quit ();
		});

    string[] profiles = Util.get_tox_profiles ();

    if (profiles != null) {
      foreach (string profile in profiles) {
  		  this.combobox_profiles.append_text (profile);
      }
    } else {
      // Set the tabpage as create page.
      this.notebook_switcher.page = 1;
    }

    this.button_login.clicked.connect (this.login);
    this.button_register.clicked.connect (this.register);

    this.show_all ();
  }

  private void login () {
    var tox_profiles_dir = Util.get_tox_profiles_dir ();
    var selected_profile = tox_profiles_dir + this.combobox_profiles.get_active_text ();

    var options = Tox.Options.create ();

    if (FileUtils.test (selected_profile, FileTest.EXISTS)) {
      FileUtils.get_data (selected_profile, out options.savedata_data);
      options.savedata_type = SaveDataType.TOX_SAVE;
      var main = new MainWindow (this.app, options, selected_profile);
      this.close ();
    } else {
      this.label_select_profile.set_text ("The selected profile doesn't exists.");
    }
  }
  private void register () {
    var tox_profiles_dir = Util.get_tox_profiles_dir ();
    var username = this.entry_register_name.get_text ().replace (" ", "-");
    var profile_name = tox_profiles_dir + username + ".tox";

    if (!FileUtils.test (profile_name, FileTest.EXISTS)) {
      var options = Tox.Options.create ();
      var main = new MainWindow (this.app, options, profile_name);
      main.entry_name.set_text (username);
      main.tox.username = username;
      main.save_profile ();
      this.close ();
    } else {
      this.label_create_profile.set_text ("Profile name already taken.");
    }
  }
}
