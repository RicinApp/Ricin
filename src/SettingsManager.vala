using LibConfig;

class SettingsManager : GLib.Object {
  private static SettingsManager? _instance;
  public static SettingsManager instance {
    get {
      if(_instance == null) {
        _instance = new SettingsManager ();
      }
      return _instance;
    }
    private set {
      _instance = value;
    }
  }

  private Config config;
  private string settings_file;

  public SettingsManager () {
    this.settings_file = "%s/ricin.cfg".printf (Tox.profile_dir ());

    this.config = new Config ();
    if (!this.config.read_file (this.settings_file)) {
      File config_file = File.new_for_path (this.settings_file);
      File config_sample = File.new_for_uri ("resource:///chat/tox/ricin/ricin.sample.cfg");

      config_sample.copy (config_file, FileCopyFlags.NONE);
      this.config.read_file (this.settings_file);
    }
  }

  private void save_settings () {
    this.config.write_file (this.settings_file);
  }

  public string get_string (string path) {
    var setting_obj = this.config.lookup (path);
    return setting_obj.get_string ();
  }

  public bool get_bool (string path) {
    var setting_obj = this.config.lookup (path);
    return (setting_obj != null) ? setting_obj.get_bool () : false;
  }

  public bool write_string (string path, string val) {
    var setting_obj = this.config.lookup (path);
    var ret_val = setting_obj.set_string (val);
    this.save_settings ();
    return ret_val;
  }

  public bool write_bool (string path, bool val) {
    var setting_obj = this.config.lookup (path);
    var ret_val = setting_obj.set_bool (val);
    this.save_settings ();
    return ret_val;
  }
}
