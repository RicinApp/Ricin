using Gdk;
using Ricin;
using Ricin.Core;
using Ricin.Utils;

namespace Ricin.Core {
  public class Contact : IPerson, Object {
    /**
    * A reference to the ToxCore instance object.
    **/
    private weak ToxCore.Tox handle;

    /**
    * The contact number within toxcore internal contacts list.
    **/
    public uint32 contact_number { get; internal set; default = -1; }

    /**
    * The contact ToxID. Identifier class allows to get nospam, checksum, etc more easily.
    **/
    public Identifier? id { get; internal set; default = null; }

    /**
    * The contact name.
    **/
    public string name { get; set; default = Constants.DEFAULT_NAME; }

    /**
    * The contact status message.
    **/
    public string status_message { get; set; default = Constants.DEFAULT_STATUS_MESSAGE; }

    /**
    * The contact presence status.
    **/
    public Presence status { get; set; default = Presence.OFFLINE; }

    /**
    * The contact avatar as a Pixbuf.
    **/
    public Pixbuf? avatar { get; set; default = null; }

    /**
    * This constructor allows to create a new contact.
    * @param {ToxCore.Tox} handle - A reference to the ToxCore instance object.
    * @param {uint32} tox_contact_number - The contact number within toxcore internal contacts list.
    * @param {uint8[]} public_key - The contact public key, used to build an Identifier.
    **/
    public Contact (ref ToxCore.Tox handle, uint32 tox_contact_number, uint8[] public_key) {
      this.handle = handle;
      this.contact_number = tox_contact_number;
      this.id = new Identifier (Utils.Helpers.bin2hex (public_key));

      this.init_signals ();
    }

    /**
    * Init the signals for this contact.
    **/
    private void init_signals () {

    }
  }
}
