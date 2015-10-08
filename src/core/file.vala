class File : GLib.Object {
  public uint32 id { get; private set; }
  public uint32 total_size { get; private set; }
  public uint32 sent_size { get; private set; }
  public string name { get; private set; }
  public string path { get; private set; }
}
