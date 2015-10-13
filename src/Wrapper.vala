using ToxCore; // only in this file

// so we don't conflict with libtoxcore
[CCode (cprefix="ToxWrapper", lower_case_cprefix="tox_wrapper_")]
namespace Tox {
  enum UserStatus {
    ONLINE,
    AWAY,
    BUSY
  }

  class Tox : Object {
    internal ToxCore.Tox handle;
    private HashTable<uint32, Friend> friends = new HashTable<uint32, Friend> (direct_hash, direct_equal);

    public string name { get; set; }
    public string status_message { get; set; }
    public UserStatus status { get; set; }
    public bool connected { get; set; default = false; }
    public string id {
      owned get {
        //uint8 address[ToxCore.ADDRESS_SIZE]; // vala bug #756376
        uint8[] address = new uint8[ToxCore.ADDRESS_SIZE];
        this.handle.self_get_address (address);
        return Util.bin2hex (address);
      }
    }

    public signal void friend_request (string id, string message);
    public signal void system_message (string message);

    //TODO
    public void set_username (string user_name) {
      debug (@"Name set to `$name`");
      this.name = user_name;
      this.handle.self_set_name (this.name.data, null);
    }

    public void set_mood (string user_status_message) {
      debug (@"Status message set to `$status_message`");
      this.status_message = user_status_message;
      this.handle.self_set_status_message (this.status_message.data, null);
    }

    public Tox (ToxCore.Options? opts = null) {
      debug ("ToxCore Version %u.%u.%u", ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH);

      this.handle = new ToxCore.Tox (opts, null);

      //this.handle.status = (ToxCore.UserStatus) this.status; // if the enum values are the same we can cast

      this.handle.callback_self_connection_status ((self, status) => {
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

      this.handle.callback_friend_connection_status ((self, num, status) => {
        if (this.friends[num] == null)
          this.friends[num] = new Friend (this, num);

        this.friends[num].connected = (status != ConnectionStatus.NONE);
      });

      this.handle.callback_friend_name ((self, num, name) => {
        this.system_message (this.friends[num].name + " is now known as " + Util.arr2str (name));
        this.friends[num].name = Util.arr2str (name);
      });

      this.handle.callback_friend_status ((self, num, status) => {
        this.friends[num].status = (UserStatus) status;
      });

      this.handle.callback_friend_status_message ((self, num, message) => {
        this.friends[num].status_message = Util.arr2str (message);
      });

      this.handle.callback_friend_message ((self, num, type, message) => {
        if (type == MessageType.NORMAL) {
          this.friends[num].message (Util.arr2str (message));
        } else {
          this.friends[num].action (Util.arr2str (message));
        }
      });

      this.handle.callback_friend_typing ((self, num, is_typing) => {
        this.friends[num].typing = is_typing;
      });

      this.handle.callback_friend_request ((self, pubkey, message) => {
        pubkey.length = ToxCore.PUBLIC_KEY_SIZE;
        string id = Util.bin2hex (pubkey);
        string msg = Util.arr2str (message);
        debug (@"Friend request from $id: $msg");
        this.friend_request (id, msg);
      });

      this.bootstrap.begin ();
    }

    public void run_loop () {
      this.schedule_loop_iteration ();
    }

    private void schedule_loop_iteration () {
      Timeout.add (this.handle.iteration_interval (), () => {
        this.handle.iterate ();
        this.schedule_loop_iteration ();
        return Source.REMOVE;
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
      var sess = new Soup.Session ();
      var msg = new Soup.Message ("GET", "https://build.tox.chat/job/nodefile_build_linux_x86_64_release/lastSuccessfulBuild/artifact/Nodefile.json");
      var stream = yield sess.send_async (msg, null);
      var json = new Json.Parser ();
      if (yield json.load_from_stream_async (stream, null)) {
        Server[] servers = {};
        var array = json.get_root ().get_object ().get_array_member ("servers");
        array.foreach_element ((arr, index, node) => {
          servers += Json.gobject_deserialize (typeof (Server), node) as Server;
        });
        while (!this.connected) {
          for (int i = 0; i < 4; ++i) { // bootstrap to 4 random nodes
            int index = Random.int_range (0, servers.length);
            debug ("Bootstrapping to %s:%llu by %s", servers[index].ipv4, servers[index].port, servers[index].owner);
            // TODO ipv6 check
            this.handle.bootstrap (
              servers[index].ipv4,
              (uint16) servers[index].port,
              Util.hex2bin (servers[index].pubkey),
              null
            );
          }

          // wait 5 seconds without blocking main loop
          Timeout.add (5000, () => {
            bootstrap.callback ();
            return Source.REMOVE;
          });
          yield;
        }
        debug ("Done bootstrapping");
      }
    }

    public Friend? add_friend (string id, string message) {
      if (id.length != ToxCore.ADDRESS_SIZE && id.index_of_char ('@') != -1) {
        error ("Invalid Tox ID");
      }

      if (message.length > ToxCore.MAX_FRIEND_REQUEST_LENGTH) {
        error ("Message too long");
      }

      ERR_FRIEND_ADD err;
      uint32 friend_num = this.handle.friend_add (Util.hex2bin (id), message.data, out err);
      if ((int) err != 0) debug ("Error code: %d", (int) err);

      if (friend_num == uint32.MAX) {
        debug ("Oops friend_num == uint3.MAX");
        return null;
      } else {
        debug (@"Sent a friend request\n--- $id\n--- $message");
        return new Friend (this, friend_num);
      }
    }

    public Friend? accept_friend_request (string id) {
      debug (@"accepting friend request from $id");
      ERR_FRIEND_ADD err;
      uint32 num = this.handle.friend_add_norequest (Util.hex2bin(id), out err);
      if (num != uint32.MAX && err == ERR_FRIEND_ADD.OK) {
        var friend = new Friend (this, num);
        this.friends[num] = friend;
        return friend;
      } else {
        error ("friend_add_norequest: %d", err);
      }
    }
  }

  class Options : Object {
    public static ToxCore.Options create () {
      // TODO: convert to exceptions
      return new ToxCore.Options (null);
    }
  }

  class Friend : Object {
    private weak Tox tox;
    private uint32 num; // libtoxcore identifier

    public Friend (Tox tox, uint32 num) {
      this.tox = tox;
      this.num = num;
    }

    public string name { get; set; }
    public UserStatus status { get; set; }
    public string status_message { get; set; }
    public bool connected { get; set; }
    public bool typing { get; set; }

    public signal void message (string message);
    public signal void action (string message);

    public void send_message (string message) {
      debug (@"sending \"$message\" to friend $num");
      ERR_FRIEND_SEND_MESSAGE err;
      tox.handle.friend_send_message (this.num, MessageType.NORMAL, message.data, out err);
    }

    public void send_action (string action_message) {
      debug (@"sending action \"$action_message\" to friend $num");
      ERR_FRIEND_SEND_MESSAGE err;
      tox.handle.friend_send_message (this.num, MessageType.ACTION, action_message.data, out err);
    }
  }
}
