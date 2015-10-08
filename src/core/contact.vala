class Contact : GLib.Object {
  public uint8[] tox_id { get; private set; } // Load it from contact save.
  public uint8[] public_key { get; private set; }

  public string name { get; set; default = "Ricin user"; }
  public string status_message { get; set; default = "Proodly using Ricin !"; }
  public UserStatus status { get; set; default = UserStatus.NONE; }
  public Gdk.Pixbuf? avatar { get; set; }
}
