class Message : GLib.Object {
  public enum Type {
    NORMAL,
    ACTION, // Action messages, similar to /me command on IRC.
    SYSTEM // Used by the client to display text in the chatform.
  }

  public uint32 id { get; private set; }
  public Type type { get; set; default = Type.NORMAL; }
  public string content { get; private set; }
  public bool was_edited { get; private set; default = false; }
  public string[] edition_history { get; private set; }
}
