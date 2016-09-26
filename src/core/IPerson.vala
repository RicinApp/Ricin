using Gdk;
using Ricin;

/**
* @interface IPerson - Defines a Tox person.
* This is used as a way to unify contacts and self profile methods/properties.
**/
public interface Ricin.IPerson : Object {
  /**
  * The person ToxID. Identifier class allows to get nospam, checksum, etc more easily.
  **/
  public abstract Identifier? id { get; internal set; default = null; }

  /**
  * The person name.
  * TODO: Fix issue:
  *   Type and/or accessors of overriding property `Ricin.Profile.name' do not match overridden property
  *   `Ricin.IPerson.name': incompatible get accessor type.
  **/
  //public abstract string name { get; set; }

  /**
  * The person status message.
  * TODO: Fix issue:
  *   Type and/or accessors of overriding property `Ricin.Profile.status_message' do not match overridden property
  *   `Ricin.IPerson.status_message': incompatible get accessor type.
  **/ 
  //public abstract string status_message { get; set; }

  /**
  * The person presence status.
  **/
  public abstract Presence status { get; set; default = Presence.OFFLINE; }

  /**
  * The person avatar as a Pixbuf.
  **/
  public abstract Pixbuf? avatar { get; set; default = null; }

  /**
  * Signal: Triggered once the name changes.
  **/
  public signal void name_changed (string old_name, string new_name);

  /**
  * Signal: Triggered once the status message changes.
  **/
  public signal void status_message_changed (string old_status_message, string new_status_message);

  /**
  * Signal: Triggered once the status (presence) changes.
  **/
  public signal void status_changed (Presence old_status, Presence new_status);

  /**
  * Signal: Triggered one the avatar changes.
  **/
  public signal void avatar_changed (Pixbuf? old_avatar, Pixbuf? new_avatar);
}
