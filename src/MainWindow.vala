public class Ricin.MainWindow : Gtk.ApplicationWindow {
    Tox.Tox tox;

    public MainWindow (Ricin app) {
        Object (application: app);

        var options = Tox.Options.create ();
        options.ipv6_enabled = true;
        options.udp_enabled = true;
        this.tox = new Tox.Tox (options);

        var sw = new Gtk.ScrolledWindow (null, null);
        var vp = new Gtk.Viewport (null, null);
        var label = new Gtk.Label (@"Your ID: $(tox.id)\n\n");
        label.selectable = true;
        vp.add (label);
        sw.add (vp);
        this.add (sw);

        tox.notify["connected"].connect ((src, prop) => {
            label.label += @"Connected: $(tox.connected)\n";
        });

        tox.friend_request.connect ((id, message) => {
            var dialog = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "Friend Request\nID: %s\n%s", id, message);
            dialog.add_buttons ("Accept", Gtk.ResponseType.ACCEPT, "Reject", Gtk.ResponseType.REJECT);
            dialog.response.connect (response => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    var friend = tox.accept_friend_request (id);
                    if (friend != null) {
                        label.label += @"Friended $id\n";
                        friend.message.connect (msg => {
                            label.label += @"$(friend.name): $msg\n";
                        });
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
