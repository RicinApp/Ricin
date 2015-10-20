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

  public static string add_markup (string text) {
    var sb = new StringBuilder ();
    foreach (string line in text.split ("\n")) { // multiple lines
      string xfmd = escape_html (line);
      if (line[0] == '>') { // greentext
        xfmd = @"<span color=\"#2ecc71\">$xfmd</span>";
      }
      sb.append (xfmd);
      sb.append_c ('\n');
    }
    sb.truncate (sb.len-1);
    return /(\w+:\S+)/.replace (sb.str, -1, 0, "<a href=\"\\1\">\\1</a>");
  }
}
