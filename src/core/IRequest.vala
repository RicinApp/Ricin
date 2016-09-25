using GLib;
using Ricin;

/**
* @enum RequestState - Defines the state a request can have.
**/
public enum Ricin.RequestState {
  PENDING,
  ACCEPTED,
  REJECTED
}

/**
* @enum RequestType - Defines the available request types.
**/
public enum Ricin.RequestType {
  CONTACT,
  GROUPCHAT
}

/**
* @interface IRequest - This interface permits to unify the different requests types/states.
* Goal of this is to have a more modular code if I want to add other requests types later.
**/
public interface Ricin.IRequest : Object {
  /**
  * The request state.
  **/
  public virtual RequestState state { get; internal set; default = RequestState.PENDING; }
  
  /**
  * The request type (contact request or groupchat request, for now).
  **/
  public virtual RequestType type { get; internal set; default = RequestType.CONTACT; }
  
  /**
  * Signal: Triggered once the request has been accepted.
  **/
  public virtual signal void state_changed (RequestState old_state, RequestState new_state);

  /**
  * Use this method to accept a request.
  **/
  public virtual void accept () {
    RequestState old_state = this.state;
    this.state = RequestState.ACCEPTED;
    this.state_changed (old_state, this.state);
  }
  
  /**
  * Use this method to reject a request.
  **/
  public virtual void reject () {
    RequestState old_state = this.state;
    this.state = RequestState.ACCEPTED;
    this.state_changed (old_state, this.state);
  }
}
