class Notification : GLib.Object {
  public uint32 id { get; private set; }
  public string title { get; set; }
  public string content { get; set; }
  public bool accept_markup { get; set; default = true; }
}
