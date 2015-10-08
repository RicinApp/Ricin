public interface IContact : GLib.Object {
  public abstract string get_name ();
  public abstract string get_alias ();
  public abstract string get_status_message_formated ();
  public abstract string get_tox_id ();
  public abstract string get_public_key ();
}

public class Contact : IContact, GLib.Object {
  public uint8[] tox_id { get; private set; } // Load it from contact save.
  public uint8[] public_key { get; private set; }
  public int friend_number { get; private set; default = -1; }

  public string name { get; set; default = "Ricin user"; }
  public string alias { get; set; default = ""; }
  public string status_message { get; set; default = "Proodly using Ricin !"; }
  public DateTime? last_seen { get; private set; default = null; }
  public UserStatus status { get; set; default = UserStatus.NONE; }
  public Gdk.Pixbuf? avatar { get; set; default = null; }

  public bool is_silenced { get; set; default =  false; }
  public bool is_blocked { get; set; default = false; }
  public bool is_typing { get; set; default = false; }
  public int unread_messages { get; set; default = 0; }

  public virtual string get_name () {}
  public virtual string get_alias () {}
  public virtual string get_tox_id () {}
  public virtual string get_public_key () {}
}
