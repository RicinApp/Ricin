using GLib;

public class Ricin.Paths : Object {
  /**
  * This static property is readonly and defines the Tox directory.
  **/
  public static string tox_directory {
    get {
      return Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox");
    }
    internal set;
  }
  
  /**
  * This static property is readonly and defines the Tox avatars directory.
  **/
  public static string tox_avatars_directory {
    get {
      return Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox", "avatars");
    }
    internal set;
  }
  
  /**
  * This static property is readonly and defines the Ricin logs directory.
  **/
  public static string tox_directory {
    get {
      return Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "ricin", "logs");
    }
    internal set;
  }
  
  /**
  * This static property is readonly and defines the Ricin directory.
  **/
  public static string ricin_directory {
    get {
      return Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "ricin");
    }
    internal set;
  }
}
