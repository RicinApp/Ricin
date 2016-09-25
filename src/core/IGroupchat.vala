using GLib;
using Ricin;

public interface Ricin.IGroupchat : Object {
  /**
  * The groupchat number within toxcore groupchat system.
  **/
  public abstract int32 group_number { get; internal set; default = -1; }

  /**
  * The groupchat name.
  **/
  public abstract string name { get; set; default = Constants.DEFAULT_GROUPCHAT_NAME; }
  
  /**
  * The groupchat peers list.
  **/
  public abstract IPerson[] peers { get; set; }
  
  /**
  * Required method to send messages.
  **/
  public abstract void send_message (string message);
  
  /**
  * Required method to send action.
  **/
  public abstract void send_action (string action);
  
  /**
  * Required method to set the groupchat topic.
  **/
  public abstract void set_topic (string topic);
  
  /**
  * Required method to get the peers list.
  **/
  public abstract IPerson[] get_peers_list ();
}
