namespace Util {
  // TAGS to replace with EMOJIS, indexes MUST match.
  public static const string[] TAGS = {
    ":+1:", ":-1:", ":@", ">:(", ":$",
    "<3", ":3", ":\\", ":'(", ":-'(",
    ":o", ":O", ":(", ":-(", ":[",
    ":-[", "xd", "xD", "Xd", "XD",
    "0:)", "o:)", "O:)", ":)", ":-)",
    ":]", ":-]", ":d", ":D", ":-D",
    ":|", ":-|", ":p", ":P", ":-p",
    ":-P", "8)", "8-)", "B:)", "B:-)",
    ":tox:", ":lock:", ":ghost:", ":alien:", ":skull:",
  };

  // EMOJIS that replaces TAGS, indexes MUST match.
  public static const string[] EMOJIS = {
    "👍", "👎", "😠", "😠", "😊",
    "💙", "🐱", "😕", "😢", "😢",
    "😵", "😵", "😦", "😦", "😦",
    "😦", "😆", "😆", "😆", "😆",
    "😇", "😇", "😇", "😄", "😄",
    "😄", "😄", "😆", "😆", "😆",
    "😐", "😐", "😛", "😛", "😛",
    "😛", "😎", "😎", "😎", "😎",
    "🔒", "🔒", "👻", "👽", "💀",
  };

  public static uint8[] hex2bin (string s) {
    uint8[] buf = new uint8[s.length / 2];
    for (int i = 0; i < buf.length; ++i) {
      int b = 0;
      s.substring (2*i, 2).scanf ("%02x", ref b);
      buf[i] = (uint8)b;
    }
    return buf;
  }

  public static string bin2hex (uint8[] bin) requires (bin.length != 0) {
    StringBuilder b = new StringBuilder ();
    for (int i = 0; i < bin.length; ++i) {
      b.append ("%02X".printf (bin[i]));
    }
    return b.str;
  }

  public inline static string arr2str (uint8[] array) {
    uint8[] str = new uint8[array.length + 1];
    Memory.copy (str, array, sizeof (uint8) * array.length);
    str[array.length] = '\0';
    string result = (string) str;
    assert (result.validate ());
    return result;
  }

  public static Gdk.Pixbuf pubkey_to_image (string pubkey, int width = 48, int height = 48) {
    var _avatar_path = Tox.profile_dir () + "avatars/" + pubkey + ".png";
    Gdk.Pixbuf pixbuf = null;

    if (FileUtils.test (_avatar_path, FileTest.EXISTS)) {
      pixbuf = new Gdk.Pixbuf.from_file_at_scale (_avatar_path, width, height, false);
    } else {
      Cairo.Surface surface = Util.identicon_for_pubkey (pubkey, width);
      pixbuf = Gdk.pixbuf_get_from_surface (surface, 0, 0, width, height);
    }

    return pixbuf;
  }

  public static string emojify (string emoji, string color = "#fcd226") {
    return @"<span face=\"EmojiOne\" foreground=\"$color\" weight=\"heavy\">$emoji</span>";
  }

  public static string escape_html (string text) {
    return Markup.escape_text (text);
  }

  private static string get_emoji_color (int index) {
    HashTable<int, string> colors = new HashTable<int, string> (direct_hash, direct_equal);
    colors.insert (5, "#e74c3c");
    colors.insert (40, "#171717");
    colors.insert (41, "#171717");
    colors.insert (42, "#3498db");
    colors.insert (43, "#27ae60");

    if (colors.contains (index)) {
      return colors.get (index);
    }

    return "#fcd226";
  }

  public static string render_emojis (string text) {
    string buffer = text;
    string color;

    for (int i = 0; i < Util.EMOJIS.length; i++) {
      buffer = buffer.replace (Util.EMOJIS[i], Util.emojify (Util.EMOJIS[i], get_emoji_color (i)));
      buffer = buffer.replace (Util.escape_html (Util.TAGS[i]), Util.emojify (Util.EMOJIS[i], get_emoji_color (i)));
    }

    return buffer;
  }

  public static string render_litemd (string text) {
    string escaped_text = escape_html (text);
    string emojified = render_emojis (escaped_text);

    // Markdown.
    // Returns plaintext as fallback in case of parsing error.
    string message = escaped_text;

    try {
      Regex code_block = new Regex ("^`((?s).*)`$", RegexCompileFlags.MULTILINE);
      MatchInfo match_info;

      if (code_block.match (escaped_text, 0, out match_info)) {
        // If message is a code block, doesn't render markdown.
        debug ("Code block regex compiled, returning monospaced text.");

        // 0 is the full text of the match, 1 is the first paren set.
        string matched_text = match_info.fetch (1);
        return @"<span face=\"monospace\" size=\"smaller\">$matched_text</span>";
      } else {
        var uri = /(\w+:\S+)/.replace (emojified, -1, 0, "<a href=\"\\1\">\\1</a>");

        var bold = /\B\*\*([^\*\*] {2,}?)\*\*\B/.replace (uri, -1, 0, "<b>\\1</b>");
        bold = /\B\*([^\*] {2,}?)\*\B/.replace (bold, -1, 0, "<b>\\1</b>");
        var italic = /^\/\/([^\/\/] {2,}?)\/\/$/.replace (bold, -1, 0, "<i>\\1</i>");
        italic = /^\/([^\/] {2,}?)\/$/.replace (italic, -1, 0, "<i>\\1</i>");
        var underlined = /\b__([^__] {2,}?)__\b/.replace (italic, -1, 0, "<u>\\1</u>");
        underlined = /\b_([^_] {2,}?)_\b/.replace (underlined, -1, 0, "<u>\\1</u>");
        var striked = /\B~~([^~~] {2,}?)~~\B/.replace (underlined, -1, 0, "<s>\\1</s>");
        striked = /\B~([^~] {2,}?)~\B/.replace (striked, -1, 0, "<s>\\1</s>");
        var inline_code = /\B`([^`]*)`\B/.replace (striked, -1, 0, "<span face=\"monospace\" size=\"smaller\">\\1</span>");

        return inline_code;
      }
    } catch (Error e) {
      debug (@"Cannot parse message, fallback to plain message.\nError: $(e.message)");
      return escaped_text;
    }
  }

  public static string add_markup (string text) {
    string markup = text; // Plaintext.
    if (Settings.instance.message_parsing_mode == 0) { // Markdown.
      markup = Util.render_litemd (text);
    }
    return markup;
  }

  public static string size_to_string (uint64 base_size) {
    double size = base_size;
    string suffix = "bytes";

    if (size >= 1073741824) {
      size = size / (double)1073741824;
      suffix = "Gb";
    } else if (size >= 1048576) {
      size = size / (double)1048576;
      suffix = "Mb";
    } else if (size >= 1024) {
      size = size / (double)1024;
      suffix = "Kb";
    } else if (size > 1) {
      size = size;
      suffix = "bytes";
    } else if (size == 1) {
      size = size;
      suffix = "bytes";
    } else {
      size = 0;
      suffix = "bytes";
    }

    return "%.*f %s".printf (2, size, suffix);
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

  public static string status_to_string (Tox.UserStatus status) {
    string str = "";

    switch (status) {
      case Tox.UserStatus.BLOCKED:
        str = _("Blocked");
        break;
      case Tox.UserStatus.ONLINE:
        str = _("Online");
        break;
      case Tox.UserStatus.AWAY:
        str = _("Away");
        break;
      case Tox.UserStatus.BUSY:
        str = _("Busy");
        break;
      case Tox.UserStatus.OFFLINE:
      default:
        str = _("Offline");
        break;
    }

    return str;
  }

  public static Cairo.Surface identicon_for_pubkey (string pubkey, int size = 48, string salt = "") {
    ToxIdenticon.ToxIdenticon identicon = new ToxIdenticon.ToxIdenticon ();
    identicon.stroke = false;
    return identicon.generate (size, pubkey, salt);
  }
}
