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
    return text.replace ("<", "&lt;").replace (">", "&gt;");
  }
}
