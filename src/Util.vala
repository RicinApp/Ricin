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
        requires (bin.length != 0)
    {
        StringBuilder b = new StringBuilder ();
        for (int i = 0; i < bin.length; ++i) {
            b.append ("%02X".printf (bin[i]));
        }
        return b.str;
    }

    public static string bin2nullterm (uint8[] data) {
        //TODO optimize this
        uint8[] buf = new uint8[data.length + 1];
        Memory.copy (buf, data, data.length);
        string sbuf = (string)buf;

        if (sbuf.validate ()) {
            return sbuf;
        }
        // Extract usable parts of the string
        StringBuilder sb = new StringBuilder ();
        for (unowned string s = sbuf; s.get_char () != 0; s = s.next_char ()) {
            unichar u = s.get_char_validated ();
            if (u != (unichar) (-1)) {
                sb.append_unichar (u);
            } else {
                stdout.printf ("Invalid UTF-8 character detected");
            }
        }
        return sb.str;
    }

    public static string arr2str (uint8[] array) {
        uint8[] name = new uint8[array.length + 1];
        GLib.Memory.copy (name, array, sizeof(uint8) * name.length);
        name[array.length] = '\0';
        return ((string) name).to_string ();
    }
}
