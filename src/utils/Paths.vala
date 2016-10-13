using GLib;
using Ricin;

namespace Ricin.Utils {
  public class Paths : Object {
    /**
    * User config directory.
    **/
    public static string config_directory = Environment.get_user_config_dir ();

    /**
    * This property is readonly and defines the Tox directory.
    **/
    public static string tox_directory = Path.build_path (Path.DIR_SEPARATOR_S, config_directory, "tox");

    /**
    * This property is readonly and defines the Tox avatars directory.
    **/
    public static string tox_avatars_directory = Path.build_path (Path.DIR_SEPARATOR_S, config_directory, "tox", "avatars");

    /**
    * This property is readonly and defines the Ricin logs directory.
    **/
    public static string ricin_logs_directory = Path.build_path (Path.DIR_SEPARATOR_S, config_directory, "ricin", "logs");

    /**
    * This property is readonly and defines the Ricin directory.
    **/
    public static string ricin_directory = Path.build_path (Path.DIR_SEPARATOR_S, config_directory, "ricin");
  }
}
