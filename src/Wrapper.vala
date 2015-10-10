using ToxCore; // only in this file

// so we don't conflict with libtoxcore
[CCode (cprefix="ToxWrapper", lower_case_cprefix="tox_wrapper_")]
namespace Tox {
	class Tox : Object {
	    private ToxCore.Tox handle;
		private HashTable<uint32, Friend> friends
			= new HashTable<uint32, Friend> (int_hash, int_equal);

		public bool connected = false;

	    public signal void friend_request (Friend friend, string message);
	    public signal void system_message (string message);

	    public Tox (Options opts) {
			this.handle = new ToxCore.Tox (opts.opts, null);
			this.handle.callback_friend_name ((self, num, name) => {
				this.friends[num].name = (string) name;
			});
			this.handle.callback_friend_status ((self, num, status) => {
				if (status == ToxCore.UserStatus.NONE)
					this.friends[num].status = UserStatus.ONLINE;
				else if (status == ToxCore.UserStatus.AWAY)
					this.friends[num].status = UserStatus.AWAY;
				else if (status == ToxCore.UserStatus.BUSY)
					this.friends[num].status = UserStatus.BUSY;
			});
	    }
	}

	class Options : Object {
	    internal ToxCore.Options opts = new ToxCore.Options (null);

		public Options () { }

	    public Options.custom (bool? ipv6_enabled = true,
	                           bool? udp_enabled= true,
	                           ProxyType proxy_type = ProxyType.NONE,
	                           string? proxy_host = null,
	                           uint16 proxy_port = 0,
	                           uint16 start_port = 0,
	                           uint16 end_port = 0,
	                           uint16 tcp_port = 0,
	                           SaveDataType savedata_type = SaveDataType.NONE,
	                           uint8[]? savedata_data = null) {
	        opts.ipv6_enabled = ipv6_enabled;
			opts.udp_enabled = udp_enabled;
			opts.proxy_type = proxy_type;
			opts.proxy_host = proxy_host;
			opts.start_port = start_port;
			opts.end_port = end_port;
			opts.tcp_port = tcp_port;
			opts.savedata_type = savedata_type;
			opts.savedata_data = savedata_data;
	    }
	}

	enum UserStatus { ONLINE, AWAY, BUSY }

	class Friend : Object {
		private weak Tox tox;
		private uint32 num; // libtoxcore identifier

		public Friend (Tox tox, string id, uint32 num) {
			Object(id: id);
			this.tox = tox;
			this.num = num;
		}

        public string id { get; construct; }
        public string name { get; set; }
        public UserStatus status { get; set; }
		public string status_message { get; set; }
        public bool connected { get; set; }
        public bool typing { get; set; }

		public signal void message (string message);
		public signal void action (string message);

		//public bool unfriend () {}

		/*
		public static bool exists (string id) {

		}
		*/
	}
}
