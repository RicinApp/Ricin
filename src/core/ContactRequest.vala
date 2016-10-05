using Ricin;
using Ricin.Core;

namespace Ricin.Core {
  public class ContactRequest : IRequest, Object {
    /**
    * The request state.
    **/
    public RequestState state { get; internal set; default = RequestState.PENDING; }

    /**
    * The request type/kind (contact request or groupchat request, for now).
    **/
    public RequestType kind { get; internal set; default = RequestType.CONTACT; }

    /**
    * The request contact's identifier built from the public key.
    **/
    public Identifier? id { get; internal set; default = null; }

    /**
    * The contact request message.
    **/
    public string request_message { get; internal set; default = ""; }

    /**
    * Construct a new contact request.
    * @param {string} public_key - The contact public key, used to build an Identifier.
    * @param {string} message - The contact request message.
    **/
    public ContactRequest (string public_key, string message) {
      this.id = new Identifier (public_key);
      this.request_message = message;
    }
  }
}
