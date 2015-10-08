class Profile : GLib.Object {
  private Profile? _instance { get; set; default = null; }
  public Profile instance {
    get {
      if (_instance == null)
        _instance = new Profile ();

      return _instance;
    };
    private set;
  }

  public uint8[] tox_id { get; private set; }
  public uint8[] public_key { get; private set; }
  private uint8[] private_key { private get; private set; }

  public string name { get; set; default = "Ricin user"; }
  public string status_message { get; set; default = "Proodly using Ricin !"; }
  public UserStatus status { get; set; default = UserStatus.NONE; }
  public Gdk.Pixbuf? avatar { get; set; }
}
