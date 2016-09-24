using GLib;

public class Ricin.Paths : Object {
  /**
  * This static property is readonly and defines the Tox directory.
  **/
  public static string tox_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox");
  
  /**
  * This static property is readonly and defines the Tox avatars directory.
  **/
  public static string tox_avatars_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox", "avatars");
  
  /**
  * This static property is readonly and defines the Ricin logs directory.
  **/
  public static string ricin_logs_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "ricin", "logs");
  
  /**
  * This static property is readonly and defines the Ricin directory.
  **/
  public static string ricin_directory = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "ricin");
}
