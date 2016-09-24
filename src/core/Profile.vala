using GLib;
using Gdk;
using Ricin;

public class Ricin.Profile : IPerson, Object {
  /**
  * The person ToxID. Identifier class allows to get nospam, checksum, etc more easily.
  **/
  public Identifier? id { get; internal set; default = null; }

  /**
  * The profile path.
  **/
  public string path { get; internal set; default = ""; }

  /**
  * The person name.
  **/
  public string name { get; set; default = Constants.DEFAULT_NAME; }

  /**
  * The person status message.
  **/
  public string status_message { get; set; default = Constants.DEFAULT_STATUS_MESSAGE; }

  /**
  * The person presence status.
  **/
  public Presence status { get; set; default = Presence.OFFLINE; }

  /**
  * The person avatar as a Pixbuf.
  **/
  public Pixbuf? avatar { get; set; default = null; }

  /**
  * The profile password, private and only used to encrypt the profile when it needs to be written on the disk.
  **/
  private string password { get; set; default = null; }

  /**
  * This constructor permits to load an existing profile.
  * @param {string} path - The profile path.
  **/
  public Profile (string path) {
    this.path = path;
    
    /**
    * TODO: Call this.load_profile.
    **/
  }

  /**
  * This constructor permits to create a new profile.
  * @param {string} name - The profile name (will be used both as a filename and username).
  * @param {string} password - The profile encryption password. If null, profile won't be encrypted.
  **/
  public Profile.create (string name, string? password = null) {
    /**
    * TODO: Create the .tox file for this new profile.
    * TODO: Set the profile name to `name`.
    * TODO: Save the default Tox state inside the newly created file.
    * TODO: If password is not null, encrypt the profile and mark the profile as encrypted.
    * TODO: Call this.load_profile.
    **/
  }

  /**
  * This method uses ToxEncrypt to determine whether or not the profile is encrypted.
  * @return {bool} - Returns true if the profile is encrypted, false if not.
  **/
  public bool is_encrypted () {
    /**
    * TODO: Use `ToxEncrypt.is_data_encrypted` on this to check if the profile is encrypted.
    **/

    return false; // Temp code, see TODO.
  }
}
