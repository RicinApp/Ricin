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
    var bold = /\B\*\*([^\*\*]*)\*\*\B/.replace (text, -1, 0, "<b>\\1</b>");
    var italic = /\b_([^_]*)_\b/.replace(bold, -1, 0, "<i>\\1</i>");
    var underline = /\B-([^-]*)-\B/.replace(italic, -1, 0, "<u>\\1</u>");
    var striked = /\B~([^~]*)~\B/.replace(underline, -1, 0, "<s>\\1</s>");

    var final_text = striked;
    return final_text;
  }

  public static string add_markup (string text) {
    var sb = new StringBuilder ();
    foreach (string line in text.split ("\n")) { // multiple lines
      string xfmd = escape_html (line);
      if (line[0] == '>') { // greentext
        xfmd = @"<span color=\"#2ecc71\"><b>$xfmd</b></span>";
      }
      sb.append (xfmd);
      sb.append_c ('\n');
    }
    sb.truncate (sb.len-1);

    var md = Util.render_litemd (sb.str);
    return /(\w+:\S+)/.replace (md, -1, 0, "<a href=\"\\1\">\\1</a>");
  }

  public static string size_to_string (uint64 size) {
    string sizeString = "";

    if (size >= 1073741824)
      sizeString = "%s Gb".printf ((size / 1073741824).to_string ());
    else if (size >= 1048576)
      sizeString = "%s Mb".printf ((size / 1048576).to_string ());
    else if (size >= 1024)
      sizeString = "%s Kb".printf ((size / 1024).to_string ());
    else if (size > 1)
      sizeString = "%s bytes".printf ((size).to_string ());
    else if (size == 1)
      sizeString = "%s byte".printf ((size).to_string ());
    else
      sizeString = "0 bytes";

    debug(@"Converted size: %s", sizeString);

    return sizeString;
  }
}
