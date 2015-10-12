[GtkTemplate (ui="/chat/tox/Ricin/main-window.ui")]
public class Ricin.MainWindow : Gtk.ApplicationWindow {
    [GtkChild] Gtk.ListBox friendlist;
    [GtkChild] Gtk.Label log;
    private ListStore friends = new ListStore (typeof (Tox.Friend));

    Tox.Tox tox;

    public MainWindow (Ricin app) {
        Object (application: app);

        this.friendlist.bind_model (this.friends, fr => new FriendListRow (fr as Tox.Friend));
        var options = Tox.Options.create ();
        options.ipv6_enabled = true;
        options.udp_enabled = true;
        this.tox = new Tox.Tox (options);

        log.label = "Your ID: " + this.tox.id + "\n\n";

        tox.notify["connected"].connect ((src, prop) => {
            log.label += @"Connected: $(tox.connected)\n";
        });

        tox.friend_request.connect ((id, message) => {
            var dialog = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "Friend Request\nID: %s\n%s", id, message);
            dialog.add_buttons ("Accept", Gtk.ResponseType.ACCEPT, "Reject", Gtk.ResponseType.REJECT);
            dialog.response.connect (response => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    var friend = tox.accept_friend_request (id);
                    if (friend != null) {
                        log.label += @"Friended $id\n";
                        friend.message.connect (msg => {
                            log.label += @"$(friend.name): $msg\n";
                        });
                        friends.append (friend);
                    }
                }
                dialog.destroy ();
            });
            dialog.show ();
        });

        tox.run_loop ();

        this.show_all ();
    }
}
