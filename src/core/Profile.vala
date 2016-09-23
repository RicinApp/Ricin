using GLib;
using Gdk;
using Ricin;

public class Ricin.Profile : IPerson, Object {
  /**
  * The person name.
  **/
  public string name { get; set; default = Constants.DEFAULT_NAME; }
  
  /**
  * The person status message.
  **/
  public string status_message { get; set; default = Constants.DEFAULT_STATUS_MESSAGE; }
  
  /**
  * The person ToxID. Identifier class allows to get nospam, checksum, etc more easily.
  **/
  public Identifier? id { get; set; default = null; }
  
  /**
  * The person presence status.
  **/
  public Presence status { get; set; default = Presence.OFFLINE; }
  
  /**
  * The person avatar as a Pixbuf.
  **/
  public Pixbuf? avatar { get; set; default = null; }
  
  /**
  * This constructor permits to load an existing profile.
  * @param {string} path - The profile path.
  **/
  public Profile (string path) {
  
  }
  
  /**
  * This constructor permits to create a new profile.
  * @param {string} name - The profile name (will be used both as a filename and username).
  * @param {string} password - The profile encryption password. If null, profile won't be encrypted.
  **/
  public Profile.create (string name, string? password = null) {
  
  }
}
