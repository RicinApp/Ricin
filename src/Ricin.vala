public class Ricin.Ricin : Gtk.Application {
    public ToxCore.Tox tox;
    private bool connected = false;

    public Ricin () {
        Object (application_id: "chat.tox.ricin",
                flags: ApplicationFlags.FLAGS_NONE);
    }

    public override void activate () {
        debug ("ToxCore Version %u.%u.%u", ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH);

        var options = ToxCore.Options () {
            ipv6_enabled = true,
            udp_enabled = true,
            proxy_type = ToxCore.ProxyType.NONE
        };

        /*
        FileUtils.get_data ("~/.config/tox/profile.tox", out options.savedata_data);
        options.savedata_type = SaveDataType.TOX_SAVE;
        */

        this.tox = new ToxCore.Tox (options, null);
        this.bootstrap.begin ();
        Timeout.add (this.tox.iteration_interval (), () => {
            this.tox.iterate ();
            return Source.CONTINUE;
        });

        this.tox.callback_self_connection_status ((handle, status) => {
            if (status != ToxCore.ConnectionStatus.NONE) {
                print ("Connected to Tox\n");
                this.connected = true;
            } else {
                print ("Disconnected\n");
                this.connected = false;
            }
        });

        new MainWindow (this);
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
                    this.tox.bootstrap (
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
}

int main(string[] args) {
    return new Ricin.Ricin ().run (args);
}
