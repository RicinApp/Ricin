using GLib;
using Ricin;

public class Ricin.GroupchatRequest : IRequest, Object {
  /**
  * The IPerson derived object of the contact who sent the request.
  **/
  public IPerson request_sender { get; internal set; }
  
  /**
  * The groupchat request message.
  **/
  public string request_message { get; internal set; default = ""; }

  /**
  * Construct a new groupchat request.
  * @param {IPerson} request_sender - The IPerson derived object of the contact who sent the request.
  * @param {string} message - The groupchat request message.
  **/
  public GroupchatRequest (IPerson request_sender, string message) {
    this.request_sender = request_sender;
    this.request_message = message;
  }
}
