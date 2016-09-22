using Gdk;
using Ricin;

/**
* @interface IPerson - Defines a Tox person.
* This is used as a way to unify contacts and self profile methods/properties.
**/
public interface Ricin.IPerson : Object {
  /**
  * The person name.
  **/
  public abstract string name { get; set; default = Constants.DEFAULT_NAME; }
  
  /**
  * The person status message.
  **/
  public abstract string status_message { get; set; default = Constants.DEFAULT_STATUS_MESSAGE; }
  
  /**
  * The person ToxID. Identifier class allows to get nospam, checksum, etc more easily.
  **/
  public abstract Identifier id { get; private set; }
  
  /**
  * The person presence status.
  **/
  public abstract Presence status { get; set; default = Presence.OFFLINE; }
  
  /**
  * The person avatar as a Pixbuf.
  **/
  public abstract Pixbuf? avatar { get; set; default = null; }
}
