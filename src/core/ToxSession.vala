using ToxCore; // only in this file
using ToxEncrypt; // only in this file
using Ricin;

/**
* This class defines various methods, signals and properties related to toxcore handling.
* This class is intended to be used as an "intermediate" class between the .vapi and the Ricin code.
**/
public class Ricin.ToxSession : Object {
  /**
  * This property allow us to stop ToxCore internal loop simply. But we'll prefer using this.toxcore_stop().
  **/
  private bool toxcore_started { get; private set; default = false; }
  
  /**
  * This property is a switch to know wheter or not Toxcore connected to the network.
  **/
  public bool toxcore_connected { get; private set; default = false; }

  /**
  * This property defines the loaded profile used in this instance.
  **/
  public Profile current_profile { get; private set; }

  /**
  * This property defines the Tox instance from libtoxcore.vapi
  **/
  internal ToxCore.Tox tox_handle { get; private set; }

  /**
  * This property aims to "cache" the options for the duration of the toxcore execution.
  **/
  public ToxCore.Options? tox_options { get; private set; default = null; }

  /**
  * We keep a list of contacts thanks to the ContactsList class.
  **/
  private ContactsList contacts_list { private get; private set; }

  /**
  * ToxSession constructor.
  * Here we init our ToxOptions, load the profile, init toxcore, etc.
  **/
  public ToxSession (Profile profile, Options options) {
    this.current_profile = profile;
    this.options = options;

    // If options is null, let's use default values.
    if (this.options == null) {
      Options opts = Options.default ();
      this.options = opts;
    }

    ERR_NEW error = null;
    this.tox_handle = new ToxCore.Tox (this.options, out error);

    switch (error) {
      case ERR_NEW.NULL:
        throw new ErrNew.Null ("One of the arguments to the function was NULL when it was not expected.");
      case ERR_NEW.MALLOC:
        throw new ErrNew.Malloc ("The function was unable to allocate enough memory to store the internal structures for the Tox object.");
      case ERR_NEW.PORT_ALLOC:
        throw new ErrNew.PortAlloc ("The function was unable to bind to a port.");
      case ERR_NEW.PROXY_BAD_TYPE:
        throw new ErrNew.BadProxy ("proxy_type was invalid.");
      case ERR_NEW.PROXY_BAD_HOST:
        throw new ErrNew.BadProxy ("proxy_type was valid but the proxy_host passed had an invalid format or was NULL.");
      case ERR_NEW.PROXY_BAD_PORT:
        throw new ErrNew.BadProxy ("proxy_type was valid, but the proxy_port was invalid.");
      case ERR_NEW.PROXY_NOT_FOUND:
        throw new ErrNew.BadProxy ("The proxy address passed could not be resolved.");
      case ERR_NEW.LOAD_ENCRYPTED:
        throw new ErrNew.LoadFailed ("The byte array to be loaded contained an encrypted save.");
      case ERR_NEW.LOAD_BAD_FORMAT:
        throw new ErrNew.LoadFailed ("The data format was invalid. This can happen when loading data that was saved by an older version of Tox, or when the data has been corrupted. When loading from badly formatted data, some data may have been loaded, and the rest is discarded. Passing an invalid length parameter also causes this error.");
      default:
        throw new ErrNew.LoadFailed ("An unknown error happenend and ToxCore wasn't able to start.");
    }

    if (error != null) { // Safety check, this should never be triggered but..
      return;
    }

    this.init_signals ();
  }
  
  private void init_signals () {
    // We get a reference of the handle, to avoid ddosing ourselves with a big contacts list.
    unowned ToxCore.Tox handle = this.tox_handle;
    
    handle.callback_self_connection_status ((self, status) => {
      switch (status) {
        case ConnectionStatus.NONE:
          debug ("Connection: None.");
          break;
        case ConnectionStatus.TCP:
          debug ("Connection: TCP.");
          break;
        case ConnectionStatus.UDP:
          debug ("Connection: UDP.");
          break;
      }

      this.toxcore_connected = (status != ConnectionStatus.NONE);
    });
  }
}
