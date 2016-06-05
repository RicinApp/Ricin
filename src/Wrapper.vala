using ToxCore; // only in this file
using ToxEncrypt; // only in this file

// so we don't conflict with libtoxcore
[CCode (cprefix="ToxWrapper", lower_case_cprefix="tox_wrapper_")]
namespace Tox {
  public enum UserStatus {
    ONLINE,
    AWAY,
    BUSY,
    BLOCKED,
    OFFLINE
  }

  public string profile_dir () {
    return Environment.get_user_config_dir () + "/tox/";
  }

  public ToxCore.UserStatus wrapper_to_core_status (UserStatus st) {
    if (st == UserStatus.AWAY) {
      return ToxCore.UserStatus.AWAY;
    }
    if (st == UserStatus.BUSY) {
      return ToxCore.UserStatus.BUSY;
    }
    return ToxCore.UserStatus.NONE;
  }

  public UserStatus core_to_wrapper_status (ToxCore.UserStatus st) {
    if (st == ToxCore.UserStatus.AWAY) {
      return UserStatus.AWAY;
    }
    if (st == ToxCore.UserStatus.BUSY) {
      return UserStatus.BUSY;
    }
    return UserStatus.ONLINE;
  }

  public errordomain ErrNew {
    Null,
    Malloc,
    PortAlloc,
    BadProxy,
    LoadFailed
  }

  public errordomain ErrDecrypt {
    Null,
    InvalidLength,
    BadFormat,
    KeyDerivationFailed,
    Failed
  }

  public errordomain ErrFriendAdd {
    Null,
    TooLong,
    NoMessage,
    OwnKey,
    AlreadySent,
    BadChecksum,
    BadNospam,
    Malloc
  }

  public errordomain ErrFriendDelete {
    NotFound
  }

  public class Tox : Object {
    internal ToxCore.Tox handle;
    private HashTable<uint32, Friend> friends = new HashTable<uint32, Friend> (direct_hash, direct_equal);

    private bool ipv6_enabled   = true;
    private string? profile     = null;
    private string? password    = null;
    internal Gdk.Pixbuf? avatar = null;

    // Used to kill tox.
    private bool must_stop = false;

    public bool encrypted { get; set; default = false; }

    public string username {
      owned get {
        uint8[] chars = new uint8[this.handle.self_get_name_size ()];
        this.handle.self_get_name (chars);
        return Util.arr2str (chars);
      }
      set {
        this.handle.self_set_name (value.data, null);
      }
    }

    public string status_message {
      owned get {
        uint8[] chars = new uint8[this.handle.self_get_status_message_size ()];
        this.handle.self_get_status_message (chars);
        return Util.arr2str (chars);
      }
      set {
        this.handle.self_set_status_message (value.data, null);
      }
    }

    public UserStatus status {
      get {
        if (connected) {
          return core_to_wrapper_status (handle.status);
        } else {
          return UserStatus.OFFLINE;
        }
      }
      set {
        this.handle.status = wrapper_to_core_status (value);
      }
    }

    public uint32 nospam {
      get {
        return this.handle.nospam;
      }
      set {
        this.handle.nospam = value;
      }
    }

    public void send_avatar (string path) {
      this.avatar = new Gdk.Pixbuf.from_file (path);
      debug (@"avatar = $path");

      foreach (var friend in friends.get_values ()) {
        friend.send_avatar ();
      }
    }

    public uint32[] self_get_friend_list () {
      size_t size = this.handle.self_get_friend_list_size ();
      uint32[] list = new uint32[size];
      this.handle.self_get_friend_list (list);

      return list;
    }

    public bool connected { get; set; default = false; }

    public string id {
      owned get {
        //uint8 address[ToxCore.ADDRESS_SIZE]; // vala bug #756376
        uint8[] address = new uint8[ToxCore.ADDRESS_SIZE];
        this.handle.self_get_address (address);
        return Util.bin2hex (address);
      }
    }

    public string pubkey {
      owned get {
        uint8[] pkey = new uint8[ToxCore.PUBLIC_KEY_SIZE];
        this.handle.self_get_public_key (pkey);
        return Util.bin2hex (pkey);
      }
    }

    public signal void friend_request (string id, string message);
    public signal void friend_online (Friend friend);
    public signal void global_info (string message);
    public signal void message_read (uint32 friend_number, uint32 message_id);

    public Tox (ToxCore.Options? opts = null, string? profile = null, string? password = null, bool is_new = false) throws ErrNew, ErrDecrypt {
      debug ("ToxCore Version %u.%u.%u", ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH);


      if (profile != null) { // Profile specified.
        this.profile = profile;
        this.password = password;

        // If profile doesn't exists, let's create it.
        if (FileUtils.test (profile, FileTest.EXISTS) == false) {
          File.new_for_path (profile).create (FileCreateFlags.NONE, null);
        }

        uint8[] tmp_save = null;
        FileUtils.get_data (this.profile, out tmp_save);

        // Profile is encrypted. Let's decrypt and load it.
        if (is_data_encrypted (tmp_save) && is_new == false) {
          opts.savedata_type = ToxCore.SaveDataType.TOX_SAVE;
          opts.savedata_data = this.decrypt_profile (this.password);
          this.encrypted = true;
        } else if (is_new) {
          opts.savedata_type = ToxCore.SaveDataType.NONE;
          this.encrypted = false;
        } else {
          uint8[] savedata = null;
          FileUtils.get_data (profile, out opts.savedata_data);
          opts.savedata_type = ToxCore.SaveDataType.TOX_SAVE;
          this.encrypted = false;
        }
      }

      this.ipv6_enabled = opts.ipv6_enabled;
      ERR_NEW error;
      this.handle = new ToxCore.Tox (opts, out error);
      unowned ToxCore.Tox handle = this.handle;

      if (is_new && this.password != null) {
        this.add_password (password);
      }

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
      }

      handle.callback_self_connection_status ((self, status) => {
        switch (status) {
          case ConnectionStatus.NONE:
            debug ("Connection: none");
            break;
          case ConnectionStatus.TCP:
            debug ("Connection: TCP");
            break;
          case ConnectionStatus.UDP:
            debug ("Connection: UDP");
            break;
        }
        this.connected = (status != ConnectionStatus.NONE);
      });

      handle.callback_friend_connection_status ((self, num, status) => {
        if (this.friends[num] == null) { // new friend
          this.friends[num] = new Friend (this, num);
          this.friend_online (this.friends[num]); // TODO
        }

        this.friends[num].connected = (status != ConnectionStatus.NONE);
        this.friends[num].send_avatar (); // Send our avatar, in case friend doesn't have it.
      });

      handle.callback_friend_name ((self, num, name) => {
        var old_name = this.friends[num].name ?? (this.friends[num].pubkey.slice (0, 16) + "...");
        var new_name = Util.arr2str (name);
        if (old_name != new_name) {
          this.friends[num].friend_info (old_name + _(" is now known as ") + new_name);
          this.friends[num].name = new_name;
        }
      });

      handle.callback_friend_status ((self, num, status) => {
        this.friends[num].set_user_status (status);
      });

      this.handle.callback_friend_status_message ((self, num, message) => {
        if (this.friends[num].blocked) {
          return;
        }

        this.friends[num].status_message = Util.arr2str (message);
      });

      this.handle.callback_friend_message ((self, num, type, message) => {
        if (this.friends[num].blocked) {
          return;
        }

        if (type == MessageType.NORMAL) {
          this.friends[num].message (Util.arr2str (message));
        } else {
          this.friends[num].action (Util.arr2str (message));
        }
      });

      this.handle.callback_friend_read_receipt ((self, friend_num, message_id) => {
        this.message_read (friend_num, message_id);
      });

      this.handle.callback_friend_typing ((self, num, is_typing) => {
        if (this.friends[num].blocked) {
          return;
        }

        this.friends[num].typing = is_typing;
      });

      handle.callback_friend_request ((self, pubkey, message) => {
        pubkey.length = ToxCore.PUBLIC_KEY_SIZE;
        string id = Util.bin2hex (pubkey);
        string msg = Util.arr2str (message);
        debug (@"Friend request from $id: $msg");
        this.friend_request (id, msg);
      });

      // send
      handle.callback_file_chunk_request ((self, friend, file, position, length) => {
        if (this.friends[friend].blocked) {
          return;
        }

        if (length == 0) { // file transfer finished
          debug (@"friend $friend, file $file: done");
          this.friends[friend].files_send.remove (file);
          this.friends[friend].file_received (file);
          return;
        }
        debug (@"friend $friend, file $file: chunk request, pos=$position, len=$length");
        this.friends[friend].file_progress (file, position);

        Bytes full_data = this.friends[friend].files_send[file];
        Bytes slice = full_data.slice ((int) position, (int) (position + length));

        ERR_FILE_SEND_CHUNK err;
        this.handle.file_send_chunk (friend, file, position, slice.get_data (), out err);

        if (err != ERR_FILE_SEND_CHUNK.OK)
          debug ("file_send_chunk: %d", err);
      });

      // recv
      this.handle.callback_file_recv_control ((self, friend, file, control) => {
        if (this.friends[friend].blocked) {
          return;
        }

        if (control == FileControl.CANCEL) {
          debug (@"friend $friend, file $file: cancelled");
          this.friends[friend].file_canceled (file);
          this.friends[friend].files_recv.remove (file);
        } else if (control == FileControl.PAUSE) {
          debug (@"friend $friend, file $file: paused");
          this.friends[friend].file_paused (file);
        } else if (control == FileControl.RESUME) {
          debug (@"friend $friend, file $file: resumed");
          this.friends[friend].file_resumed (file);
        } else {
          assert_not_reached ();
        }
      });

      // recv
      this.handle.callback_file_recv ((self, friend, file, kind, size, filename) => {
        if (this.friends[friend].blocked) {
          this.handle.file_control (friend, file, FileControl.CANCEL, null);
          return;
        }

        if (kind == FileKind.AVATAR) {
          debug (@"friend $friend, file $file: receive avatar");
          this.friends[friend].files_recv[file] = new FileDownload.avatar ();
          this.handle.file_control (friend, file, FileControl.RESUME, null);
        } else {
          debug (@"friend $friend, file $file: file_recv");
          this.friends[friend].files_recv[file] = new FileDownload (Util.arr2str (filename));
          this.friends[friend].file_transfer (Util.arr2str (filename), size, file);
        }
      });

      // recv
      this.handle.callback_file_recv_chunk ((self, friend, file, position, data) => {
        if (this.friends[friend].blocked) {
          this.handle.file_control (friend, file, FileControl.CANCEL, null);
          return;
        }

        var fr = this.friends[friend];
        assert (fr.files_recv.contains (file));
        if (data.length == 0) {
          debug (@"friend $friend, file $file: done");
          FileDownload dl = fr.files_recv[file];
          Bytes bytes = ByteArray.free_to_bytes (dl.data);
          if (dl.kind == FileKind.AVATAR) {
            try {
              var stream = new MemoryInputStream.from_bytes (bytes);
              var pixbuf = new Gdk.Pixbuf.from_stream_at_scale (stream, 48, 48, true);
              fr.avatar (pixbuf);
            } catch (Error e) {
              warning ("Error processing avatar for %s: %s", fr.name, e.message);
            }
          } else {
            fr.file_done (dl.name, bytes, file);
          }
          fr.files_recv.remove (file);
          return;
        }

        debug (@"friend $friend, file $file: chunk request, pos=$position");
        this.friends[friend].file_progress (file, position);

        assert (fr.files_recv[file].data.len == position);
        fr.files_recv[file].data.append (data);
      });

      this.bootstrap.begin ();
    }

    public void disconnect () {
      this.must_stop = true;
      this.handle.kill ();
    }

    public void run_loop () {
      this.schedule_loop_iteration ();
    }

    private void schedule_loop_iteration () {
      Timeout.add (this.handle.iteration_interval (), () => {
        if (this.must_stop) {
          return true;
        }

        this.handle.iterate ();
        this.schedule_loop_iteration ();
        //return Source.REMOVE;
        return false;
      });
    }

    private class Server : Object {
      public string owner { get; set; }
      public string region { get; set; }
      public string ipv4 { get; set; }
      public string ipv6 { get; set; }
      public uint64 port { get; set; }
      public string pubkey { get; set; }
    }

    private async void bootstrap () {
      var json = new Json.Parser ();
      var bytes = resources_lookup_data ("/chat/tox/ricin/nodes.json", ResourceLookupFlags.NONE);
      if (json.load_from_data ((string) bytes.get_data (), bytes.length)) {
        Server[] servers = {};
        var array = json.get_root ().get_object ().get_array_member ("servers");
        array.foreach_element ((arr, index, node) => {
          servers += Json.gobject_deserialize (typeof (Server), node) as Server;
        });
        while (!this.connected) {
          for (int i = 0; i < 4; ++i) { // bootstrap to 4 random nodes
            Server srv = servers[Random.int_range (0, servers.length)];

            bool success = false;
            bool try_ipv6 = this.ipv6_enabled && srv.ipv6 != null;
            if (!success && try_ipv6) {
              debug ("UDP bootstrap %s:%llu by %s", srv.ipv6, srv.port, srv.owner);
              success = this.handle.bootstrap (srv.ipv6, (uint16) srv.port, Util.hex2bin (srv.pubkey), null);
            }
            if (!success) {
              debug ("UDP bootstrap %s:%llu by %s", srv.ipv4, srv.port, srv.owner);
              success = this.handle.bootstrap (srv.ipv4, (uint16) srv.port, Util.hex2bin (srv.pubkey), null);
            }
            if (!success && try_ipv6) {
              debug ("TCP bootstrap %s:%llu by %s", srv.ipv6, srv.port, srv.owner);
              success = this.handle.add_tcp_relay (srv.ipv6, (uint16) srv.port, Util.hex2bin (srv.pubkey), null);
            }
            if (!success) {
              debug ("TCP bootstrap %s:%llu by %s", srv.ipv4, srv.port, srv.owner);
              success = this.handle.add_tcp_relay (srv.ipv4, (uint16) srv.port, Util.hex2bin (srv.pubkey), null);
            }
          }

          // wait 5 seconds without blocking main loop
          Timeout.add (5000, () => {
            bootstrap.callback ();
            //return Source.REMOVE;
            return false;
          });
          yield;
        }
        debug ("Done bootstrapping");
      }
    }

    public Friend? add_friend (string id, string message) throws ErrFriendAdd {
      if (id.length != ToxCore.ADDRESS_SIZE && id.index_of_char ('@') != -1) {
        error ("Invalid Tox ID");
      }

      ERR_FRIEND_ADD err;
      uint32 friend_num = this.handle.friend_add (Util.hex2bin (id), message.data, out err);

      switch (err) {
        case ERR_FRIEND_ADD.OK:
          return new Friend (this, friend_num);
        case ERR_FRIEND_ADD.NULL:
          throw new ErrFriendAdd.Null ("One of the arguments to the function was NULL when it was not expected.");
        case ERR_FRIEND_ADD.TOO_LONG:
          throw new ErrFriendAdd.TooLong ("The friend request message is too long.");
        case ERR_FRIEND_ADD.NO_MESSAGE:
          throw new ErrFriendAdd.NoMessage ("The friend request message was empty.");
        case ERR_FRIEND_ADD.OWN_KEY:
          throw new ErrFriendAdd.OwnKey ("You cannot add yourself.");
        case ERR_FRIEND_ADD.ALREADY_SENT:
          throw new ErrFriendAdd.AlreadySent ("You already added this friend.");
        case ERR_FRIEND_ADD.BAD_CHECKSUM:
          throw new ErrFriendAdd.BadChecksum ("ToxID is invalid.");
        case ERR_FRIEND_ADD.SET_NEW_NOSPAM:
          throw new ErrFriendAdd.BadNospam ("This ToxID have a new nospam.");
        case ERR_FRIEND_ADD.MALLOC:
          throw new ErrFriendAdd.Malloc ("A memory allocation failed when trying to increase the friend list size.");
        default:
          return null;
      }
    }

    public Friend? accept_friend_request (string id) throws ErrFriendAdd {
      if (id.length != ToxCore.PUBLIC_KEY_SIZE && id.index_of_char ('@') != -1) {
        error ("Invalid Public Key");
      }

      debug (@"Accepting friend request from $id");
      ERR_FRIEND_ADD err;
      uint32 friend_num = this.handle.friend_add_norequest (Util.hex2bin(id), out err);

      switch (err) {
        case ERR_FRIEND_ADD.OK:
          debug (@"$id friend number: $friend_num");
          return this.add_friend_by_num (friend_num);
        case ERR_FRIEND_ADD.NULL:
          throw new ErrFriendAdd.Null ("One of the arguments to the function was NULL when it was not expected.");
        case ERR_FRIEND_ADD.TOO_LONG:
          throw new ErrFriendAdd.TooLong ("The friend request message is too long.");
        case ERR_FRIEND_ADD.NO_MESSAGE:
          throw new ErrFriendAdd.NoMessage ("The friend request message was empty.");
        case ERR_FRIEND_ADD.OWN_KEY:
          throw new ErrFriendAdd.OwnKey ("You cannot add yourself.");
        case ERR_FRIEND_ADD.ALREADY_SENT:
          throw new ErrFriendAdd.AlreadySent ("You already added this friend.");
        case ERR_FRIEND_ADD.BAD_CHECKSUM:
          throw new ErrFriendAdd.BadChecksum ("ToxID is invalid.");
        case ERR_FRIEND_ADD.SET_NEW_NOSPAM:
          throw new ErrFriendAdd.BadNospam ("This ToxID have a new nospam.");
        case ERR_FRIEND_ADD.MALLOC:
          throw new ErrFriendAdd.Malloc ("A memory allocation failed when trying to increase the friend list size.");
        default:
          return null;
      }
    }

    public Friend? add_friend_by_num (uint32 num) {
      debug (@"Adding friend: $num");
      var friend = new Friend (this, num);
      this.friends[num] = friend;
      return friend;
    }

    public void save_data (string? pass = null) throws ErrDecrypt {
      if (this.profile != null) {
        debug ("Saving data to " + this.profile);

        uint8[] savedata = null;
        uint8[] data = new uint8[this.handle.get_savedata_size ()];
        this.handle.get_savedata (data);

        if (this.password != null) {
          savedata = this.encrypt_profile (this.password, data);
        } else {
          savedata = data;
        }

        FileUtils.set_data (this.profile, savedata);
      }
    }

    public uint8[] encrypt_profile (string password, uint8[]? data = null) throws ErrDecrypt {
      ERR_ENCRYPTION err;
      uint8[] pass = password.data;
      uint8[] savedata = null;

      if (data == null) {
        savedata = new uint8[this.handle.get_savedata_size ()];
        this.handle.get_savedata (savedata);
      } else {
        savedata = data;
      }

      if (is_data_encrypted (savedata)) {
        throw new ErrDecrypt.Failed ("Profile is already encrypted, cannot encrypt non-decrypted data.");
      }

      uint32 savesize = savedata.length + ToxEncrypt.PASS_ENCRYPTION_EXTRA_LENGTH;
      uint8[] encrypted_data = new uint8[savesize];
      pass_encrypt (savedata, pass, encrypted_data, out err);
      this.password = password;

      if (err != ERR_ENCRYPTION.OK) {
        switch (err) {
          case ERR_ENCRYPTION.NULL:
            throw new ErrDecrypt.Null ("Some input data, or maybe the output pointer, was null.");
          case ERR_ENCRYPTION.KEY_DERIVATION_FAILED:
            throw new ErrDecrypt.KeyDerivationFailed ("The crypto lib was unable to derive a key from the given passphrase, which is usually a lack of memory issue. The functions accepting keys do not produce this error.");
          case ERR_ENCRYPTION.FAILED:
            throw new ErrDecrypt.Failed ("The encryption itself failed.");
        }
      }

      //this.encrypted = true;
      return encrypted_data;
    }

    public uint8[] decrypt_profile (string password) throws ErrDecrypt {
      ERR_DECRYPTION err;
      uint8[]? savedata = null;
      uint8[] pass = password.data;
      FileUtils.get_data (this.profile, out savedata);

      if (is_data_encrypted (savedata) == false) {
        throw new ErrDecrypt.Failed ("Profile isn't encrypted, cannot decrypt plain text.");
      }

      int savesize = savedata.length - ToxEncrypt.PASS_ENCRYPTION_EXTRA_LENGTH;
      uint8[] decrypted_data = new uint8[savesize];

      pass_decrypt (savedata, pass, decrypted_data, out err);
      //this.password = null;

      if (err != ERR_DECRYPTION.OK) {
        switch (err) {
          case ERR_DECRYPTION.NULL:
            throw new ErrDecrypt.Null ("Some input data, or maybe the output pointer, was null.");
          case ERR_DECRYPTION.INVALID_LENGTH:
            throw new ErrDecrypt.InvalidLength ("The input data was shorter than TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes.");
          case ERR_DECRYPTION.BAD_FORMAT:
            throw new ErrDecrypt.BadFormat ("The input data is missing the magic number (i.e. wasn't created by this module, or is corrupted).");
          case ERR_DECRYPTION.KEY_DERIVATION_FAILED:
            throw new ErrDecrypt.KeyDerivationFailed ("The crypto lib was unable to derive a key from the given passphrase, which is usually a lack of memory issue. The functions accepting keys do not produce this error.");
          case ERR_DECRYPTION.FAILED:
            throw new ErrDecrypt.Failed ("The encrypted byte array could not be decrypted. Either the data was corrupt or the password/key was incorrect.");
        }
      }

      //this.encrypted = false;
      return decrypted_data;
    }

    public bool add_password (string password) {
      try {
        uint8[] data = this.encrypt_profile (password, null);
        FileUtils.set_data (this.profile, data);
        this.encrypted = true;

        return data != null;
      } catch (Error e) {
        return false;
      }
    }

    public bool change_password (string old_password, string new_password) {
      try {
        uint8[] data = this.decrypt_profile (old_password);
        uint8[] data2 = this.encrypt_profile (new_password, data);
        this.password = new_password;
        FileUtils.set_data (this.profile, data2);

        return data2 != null;
      } catch (Error e) {
        return false;
      }
    }

    public bool remove_password (string old_password) {
      try {
        uint8[] data = this.decrypt_profile (old_password);
        this.password = null;
        this.encrypted = false;
        FileUtils.set_data (this.profile, data);

        return data != null;
      } catch (Error e) {
        return false;
      }
    }
  }

  public class Options : Object {
    public static ToxCore.Options copy (ToxCore.Options o) {
      var opts = create ();
      opts.ipv6_enabled = o.ipv6_enabled;
      opts.udp_enabled = o.udp_enabled;
      opts.proxy_type = o.proxy_type;
      opts.proxy_host = o.proxy_host;
      opts.proxy_port = o.proxy_port;
      opts.start_port = o.end_port;
      opts.tcp_port = o.tcp_port;
      opts.savedata_type = o.savedata_type;
      opts.savedata_data = o.savedata_data;
      return opts;
    }

    public static ToxCore.Options create () {
      // TODO: convert to exceptions
      return new ToxCore.Options (null);
    }
  }

  public class Friend : Object {
    private weak Tox tox;
    public uint32 num; // libtoxcore identifier
    public uint position;
    // Bytes is immutable
    internal HashTable<uint32, Bytes> files_send = new HashTable<uint32, Bytes> (direct_hash, direct_equal);
    // ByteArray is mutable
    internal HashTable<uint32, FileDownload> files_recv = new HashTable<uint32, FileDownload> (direct_hash, direct_equal);

    /* We could implement this as just a get { } that goes to libtoxcore, and
     * use GLib.Object.notify_property () in the callbacks, but the name is not
     * set until we leave the callback so we'll just keep our own copy.
     */
    public string name { get; set; }
    public string status_message { get; set; }

    public string pubkey {
      owned get {
        uint8[] chars = new uint8[ToxCore.PUBLIC_KEY_SIZE];
        tox.handle.friend_get_public_key (num, chars, null);
        return Util.bin2hex (chars);
      }
    }

    public UserStatus status { get; private set; }
    public bool connected { get; set; }
    public bool typing { get; set; }
    public bool blocked { get; set; default = false; }

    public signal void message (string message);
    public signal void action (string message);
    public signal void avatar (Gdk.Pixbuf pixbuf);
    public signal void friend_info (string message);
    public signal void file_transfer (string filename, uint64 file_size, uint32 id);
    public signal void file_paused (uint32 id);
    public signal void file_progress (uint32 id, uint64 position);
    public signal void file_resumed (uint32 id);
    public signal void file_done (string filename, Bytes data, uint32 id);
    public signal void file_canceled (uint32 id);
    public signal void file_received (uint32 id);

    public Friend (Tox tox, uint32 num) {
      this.tox = tox;
      this.num = num;

      this.notify["connected"].connect ((o, p) => update_user_status ());
      this.notify["blocked"].connect ((o, p) => update_user_status ());

      this.avatar.connect ((pixbuf) => {
        string profile_dir = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), "tox");
        string avatars_dir = Path.build_path (Path.DIR_SEPARATOR_S, profile_dir, "avatars");
        File file_avatar = File.new_for_path (Path.build_path (Path.DIR_SEPARATOR_S, avatars_dir, this.pubkey + ".png"));

        uint8[] pixels;
        pixbuf.save_to_buffer (out pixels, "png");

        FileUtils.set_data (file_avatar.get_path (), pixels);
      });
    }

    public string get_uname () {
      uint8[] text = new uint8[ToxCore.MAX_NAME_LENGTH];
      this.tox.handle.friend_get_name (this.num, text, null);

      return (string) text;
    }

    public string get_ustatus_message () {
      uint8[] text = new uint8[ToxCore.MAX_STATUS_MESSAGE_LENGTH];
      this.tox.handle.friend_get_status_message (this.num, text, null);

      return (string) text;
    }

    public string last_online (string? format) {
      uint64 last = this.tox.handle.friend_get_last_online (this.num, null);
      //debug (@" for $num: $last");

      DateTime time = new DateTime.from_unix_local ((int64)last);
      return time.format((format != null) ? format : _("<b>Last online:</b>") + " %H:%M %d/%m/%Y");
    }

    public void set_user_status (ToxCore.UserStatus status) {
      if (blocked) {
        this.status = UserStatus.BLOCKED;
      } else if (!connected) {
        this.status = UserStatus.OFFLINE;
      } else {
        this.status = core_to_wrapper_status (status);
      }
    }

    public void update_user_status () {
      this.set_user_status (tox.handle.friend_get_status (num, null));
    }

    public void reply_file_transfer (bool accept, uint32 id) {
      tox.handle.file_control (this.num, id, accept ? FileControl.RESUME : FileControl.CANCEL, null);
    }

    public uint32 send_message (string message) {
      ERR_FRIEND_SEND_MESSAGE err;
      return tox.handle.friend_send_message (this.num, MessageType.NORMAL, message.data, out err);
    }

    public void send_action (string action_message) {
      ERR_FRIEND_SEND_MESSAGE err;
      tox.handle.friend_send_message (this.num, MessageType.ACTION, action_message.data, out err);
    }

    public void send_avatar () {
      if (tox.avatar != null) {
        uint8[] pixels;
        tox.avatar.save_to_buffer (out pixels, "png");

        uint8[] avatar_id = new uint8[ToxCore.HASH_LENGTH];
        ToxCore.Tox.hash (avatar_id, pixels);

        ERR_FILE_SEND err;
        uint32 transfer = this.tox.handle.file_send (this.num, FileKind.AVATAR, pixels.length, avatar_id, null, out err);
        if (err != ERR_FILE_SEND.OK) {
          debug ("tox_file_send: %d", err);
        }

        this.files_send[transfer] = new Bytes (pixels);
      }
    }

    public uint32 send_file (string path) {
      var file = File.new_for_path (path);
      var info = file.query_info ("standard::size", FileQueryInfoFlags.NONE);
      var id = this.tox.handle.file_send (this.num, FileKind.DATA, info.get_size (), null, file.get_basename ().data, null);
      uint8[] data;
      FileUtils.get_data (path, out data);
      this.files_send[id] = new Bytes.take (data);

      return id;
    }

    public uint32 send_image (Gdk.Pixbuf pixbuf, string name) {
      uint8[] data;
      pixbuf.save_to_buffer (out data, "png");
      var id = this.tox.handle.file_send (this.num, FileKind.DATA, data.length, null, name.data, null);
      this.files_send[id] = new Bytes.take (data);

      return id;
    }

    public void send_typing (bool is_typing) {
      this.tox.handle.self_set_typing (this.num, is_typing, null);
    }

    public bool delete () throws ErrFriendDelete {
      ERR_FRIEND_DELETE err;
      var retval = this.tox.handle.friend_delete (this.num, out err);

      switch (err) {
        case ERR_FRIEND_DELETE.FRIEND_NOT_FOUND:
          throw new ErrFriendDelete.NotFound ("There was no friend with the given friend number. No friends were deleted.");
      }

      return retval;
    }
  }

  private class FileDownload : Object {
    public FileKind kind;
    public string? name = null;
    //public bool paused = false;
    public ByteArray data = new ByteArray ();

    public FileDownload (string name) {
      this.name = name;
      this.kind = FileKind.DATA;
    }

    public FileDownload.avatar () {
      this.kind = FileKind.AVATAR;
    }
  }
}
