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
    return Markup.escape_text (text);
  }

  public static string render_litemd (string text) {
    var md = escape_html (text);

    // Emojis.

    // Markdown.
    var bold = /\B\*\*([^\*\*]*)\*\*\B/.replace (md, -1, 0, "<b>\\1</b>");
    var italic = /\b_([^_]*)_\b/.replace(bold, -1, 0, "<i>\\1</i>");
    var underlined = /\B-([^-]*)-\B/.replace(italic, -1, 0, "<u>\\1</u>");
    var striked = /\B~([^~]*)~\B/.replace(underlined, -1, 0, "<s>\\1</s>");
    var uri = /(\w+:\/?\/?[^\s]+)/.replace (striked, -1, 0, "<span color=\"#2a92c6\"><a href=\"\\1\">\\1</a></span>");

    var emojis = uri.replace (":)", "😄")
                 .replace (":+1:", "👍")
                 .replace (":-1:", "👎")
                 .replace (":@", "😠")
                 .replace (">:(", "😠")
                 .replace (":$", "😊")
                 .replace ("<3", "💙")
                 .replace (":3", "🐱")
                 .replace (":\\", "😕")
                 .replace (":'(", "😢")
                 .replace (":-'(", "😢")
                 .replace (":o", "😵")
                 .replace (":O", "😵")
                 .replace (":(", "😦")
                 .replace (":-(", "😦")
                 .replace (":-[", "😦")
                 .replace (":[", "😦")
                 .replace ("xD", "😁")
                 .replace ("XD", "😁")
                 .replace ("0:)", "😇")
                 .replace (":D", "😆")
                 .replace (":-D", "😆")
                 .replace (":|", "😐")
                 .replace (":-|", "😐")
                 .replace (":p", "😛")
                 .replace (":-p", "😛")
                 .replace (":P", "😛")
                 .replace (":-P", "😛")
                 .replace ("8)", "😎")
                 .replace ("8-)", "😎");

    var message = emojis;
    debug (@"Message: $message");

    return message;
  }

  public static string add_markup (string text) {
    var md = Util.render_litemd (text);
    var sb = new StringBuilder ();

    foreach (string line in md.split ("\n")) { // multiple lines
      string tmp = line;

      if (line.index_of ("&gt;", 0) == 0) { // greentext
        tmp = @"<span color=\"#2ecc71\"><b>$tmp</b></span>";
      }
      sb.append (tmp);
      sb.append_c ('\n');
    }

    sb.truncate (sb.len-1);
    return (string) sb.data;
  }

  public static string size_to_string (uint64 size) {
    string sizeString = "";

    if (size >= 1073741824) {
      sizeString = "%s Gb".printf ((size / 1073741824).to_string ());
    } else if (size >= 1048576) {
      sizeString = "%s Mb".printf ((size / 1048576).to_string ());
    } else if (size >= 1024) {
      sizeString = "%s Kb".printf ((size / 1024).to_string ());
    } else if (size > 1) {
      sizeString = "%s bytes".printf ((size).to_string ());
    } else if (size == 1) {
      sizeString = "%s byte".printf ((size).to_string ());
    } else {
      sizeString = "0 bytes";
    }

    debug(@"Converted size: %s", sizeString);

    return sizeString;
  }

  public static string status_to_icon (Tox.UserStatus status, int messagesCount = 0) {
    string icon = "";

    switch (status) {
      case Tox.UserStatus.BLOCKED:
        icon = (messagesCount > 0) ? "invisible" : "invisible";
        break;
      case Tox.UserStatus.ONLINE:
        icon = (messagesCount > 0) ? "online_notification" : "online";
        break;
      case Tox.UserStatus.AWAY:
        icon = (messagesCount > 0) ? "idle_notification" : "idle";
        break;
      case Tox.UserStatus.BUSY:
        icon = (messagesCount > 0) ? "busy_notification" : "busy";
        break;
      case Tox.UserStatus.OFFLINE:
      default:
        icon = (messagesCount > 0) ? "offline_notification" : "offline";
        break;
    }

    return icon;
  }
}
