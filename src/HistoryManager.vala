class HistoryManager {
  private static ThemeManager? _instance;
  public static ThemeManager instance {
    get {
      if (_instance == null) {
        _instance = new ThemeManager ();
      }
      return _instance;
    }
    private set {
      _instance = value;
    }
  }

  private string logs_path = "%s/logs".printf (Tox.profile_dir ());

  public HistoryManager (string pubkey) {
    this.start (pubkey);
  }

  private void start (string pubkey) {
    debug ("Started history manager...");
    debug (@"Logs path: $logs_path");
  }

  private void load_history (Tox.Friend friend) {
    try {
      // Create a file that can only be accessed by the current user:
      File file = File.new_for_path ("my-test.bin");
      FileIOStream ios = file.create_readwrite (FileCreateFlags.PRIVATE);

      //
      // Set the file pointer to the beginning of the stream:
      //
      assert (ios.can_seek ());
      ios.seek (0, SeekType.SET);

      //
      // Read n bytes:
      //
      FileInputStream @is = ((FileInputStream) ios.input_stream);

      // Output: ``M``
      uint8 buffer[1];
      size_t size = @is.read (buffer);
      stdout.write (buffer, size);

      // Output: ``y 1. line``
      DataInputStream dis = new DataInputStream (@is);
      string str = dis.read_line ();
      stdout.printf ("%s\n", str);

      // Output: ``My 2. line``
      str = dis.read_line ();
      stdout.printf ("%s\n", str);

      // Output: ``My 3. line``
      str = dis.read_line ();
      stdout.printf ("%s\n", str);

      // Output: ``10``
      int16 i = dis.read_int16 ();
      stdout.printf ("%d\n", i);
    } catch (Error e) {
      stdout.printf ("Error: %s\n", e.message);
    }
  }

  public void write (string friend_pubkey, string text) {
    /*try {
      // Create a file that can only be accessed by the current user:
      var history_path = @"$logs_path/$friend_pubkey.log";

      File logs_file;
      FileIOStream ios;

      if (FileUtils.test (history_path, FileTest.EXISTS) == false) {
        debug ("No log file for this friend, creating it...");
        logs_file = File.new_for_path (history_path);
        ios = logs_file.create_readwrite (FileCreateFlags.PRIVATE);
      } else {
        debug ("Log file for this friend found, opening it...");
        logs_file = File.new_for_path (@"$logs_path/$friend_pubkey.log");
        ios = logs_file.open_readwrite ();
      }

      size_t bytes_written;
      FileOutputStream os = ios.output_stream as FileOutputStream;
      DataOutputStream dos = new DataOutputStream (os);
      dos.put_string (@"$text");
      dos.put_string ("\n");
      //dos.put_int16 (10);
    } catch (Error e) {
      stdout.printf ("Error: %s\n", e.message);
    }*/
  }
}
