using GLib;

namespace Ricin.Paths {
  /**
  * User config directory.
  **/
  public string config_directory = Environment.get_user_config_dir ();

  /**
  * This property is readonly and defines the Tox directory.
  **/
  public string tox_directory = Path.build_path (Path.DIR_SEPARATOR_S, Path.config_directory, "tox");
  
  /**
  * This property is readonly and defines the Tox avatars directory.
  **/
  public string tox_avatars_directory = Path.build_path (Path.DIR_SEPARATOR_S, Path.config_directory, "tox", "avatars");
  
  /**
  * This property is readonly and defines the Ricin logs directory.
  **/
  public string ricin_logs_directory = Path.build_path (Path.DIR_SEPARATOR_S, Path.config_directory, "ricin", "logs");
  
  /**
  * This property is readonly and defines the Ricin directory.
  **/
  public string ricin_directory = Path.build_path (Path.DIR_SEPARATOR_S, Path.config_directory, "ricin");
}
