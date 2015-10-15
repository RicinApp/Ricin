namespace Util {
  public static uint8[] hex2bin (string s) {
    uint8[] buf = new uint8[s.length / 2];
    for (int i = 0; i < buf.length; ++i) {
      int b = 0;
      s.substring (2*i, 2).scanf ("%02x", ref b);
      buf[i] = (uint8)b;
    }
    return buf;
  }

  public static string bin2hex (uint8[] bin)
  requires (bin.length != 0) {
    StringBuilder b = new StringBuilder ();
    for (int i = 0; i < bin.length; ++i) {
      b.append ("%02X".printf (bin[i]));
    }
    return b.str;
  }

  public inline static string arr2str (uint8[] array) {
    uint8[] str = new uint8[array.length + 1];
    Memory.copy (str, array, sizeof(uint8) * array.length);
    str[array.length] = '\0';
    string result = (string) str;
    assert (result.validate ());
    return result;
  }

  public static string escape_html (string text) {
    return text
      .replace ("&", "&amp;")
      .replace ("<", "&lt;")
      .replace (">", "&gt;");
  }

  public static string add_markup (string text) {
    var sb = new StringBuilder ();
    foreach (string line in text.split ("\n")) { // multiple lines
      string xfmd = escape_html (line);
      if (line[0] == '>') // greentext
        xfmd = @"<span color=\"#2ecc71\">$xfmd</span>";
      sb.append (xfmd);
      sb.append_c ('\n');
    }
    sb.truncate (sb.len-1);
    return sb.str;
  }

  public static string get_tox_profiles_dir () {
    return Environment.get_home_dir () + "/.config/tox/";
  }

  public static string[]? get_tox_profiles () {
    var dir = Util.get_tox_profiles_dir ();
    var config_dir = File.new_for_path (dir);
    string[] files = {};
    if (!config_dir.query_exists ()) {
      config_dir.make_directory ();
    } else {
      var enumerator = config_dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);
      FileInfo info;
      while ((info = enumerator.next_file ()) != null) {
        if (info.get_name ().has_suffix (".tox")) {
          files += info.get_name ();
        }
      }

      return files;
    }

    return null;
  }

  public static bool save_data (ref Tox.Tox handle, string path) {
    debug ("Saving data to " + path);
    uint32 size = handle.get_savedata_size ();
    uint8[] buffer = new uint8[size];
    handle.get_savedata (buffer);
    return FileUtils.set_data (path, buffer);
  }
}
