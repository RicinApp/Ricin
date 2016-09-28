using GLib;

namespace Ricin.Paths {
  /**
  * This property is readonly and defines the Tox directory.
  **/
  public string tox_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox");
  
  /**
  * This property is readonly and defines the Tox avatars directory.
  **/
  public string tox_avatars_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox", "avatars");
  
  /**
  * This property is readonly and defines the Ricin logs directory.
  **/
  public string ricin_logs_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "ricin", "logs");
  
  /**
  * This property is readonly and defines the Ricin directory.
  **/
  public string ricin_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "ricin");
}
