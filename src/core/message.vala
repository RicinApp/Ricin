class Message : GLib.Object {
  public uint32 id { get; private set; }
  public string content { get; private set; }
  public bool was_edited { get; private set; default = false; }
  public string[] edition_history { get; private set; }
}
