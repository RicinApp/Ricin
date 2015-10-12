[GtkTemplate (ui="/chat/tox/Ricin/main-window.ui")]
public class Ricin.MainWindow : Gtk.ApplicationWindow {
    [GtkChild] Gtk.ListBox friendlist;

    [GtkChild] Gtk.Image connection_image;
    [GtkChild] Gtk.Label id_label;

    [GtkChild] Gtk.ListBox messages_list;

    [GtkChild] Gtk.Entry entry;
    [GtkChild] Gtk.Button send;

    private ListStore friends = new ListStore (typeof (Tox.Friend));
    private ListStore messages = new ListStore (typeof (Gtk.Label));

    Tox.Tox tox;

    public MainWindow (Ricin app) {
        Object (application: app);

        this.friendlist.bind_model (this.friends, fr => new FriendListRow (fr as Tox.Friend));
        this.messages_list.bind_model (this.messages, l => l as Gtk.Widget);

        var options = Tox.Options.create ();
        options.ipv6_enabled = true;
        options.udp_enabled = true;
        this.tox = new Tox.Tox (options);

        id_label.label += this.tox.id;

        send.clicked.connect (() => {
            var label = new Gtk.Label ("Me: " +entry.text);
            label.halign = Gtk.Align.START;
            messages.append (label);
            (friends.get_item (0) as Tox.Friend).send_message (entry.text);
            entry.text = "";
        });

        tox.notify["connected"].connect ((src, prop) => {
            this.connection_image.icon_name = tox.connected ? "gtk-yes" : "gtk-no";
        });

        tox.friend_request.connect ((id, message) => {
            var dialog = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "Friend Request\nID: %s\n%s", id, message);
            dialog.add_buttons ("Accept", Gtk.ResponseType.ACCEPT, "Reject", Gtk.ResponseType.REJECT);
            dialog.response.connect (response => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    var friend = tox.accept_friend_request (id);
                    if (friend != null) {
                        friends.append (friend);
                        friend.message.connect (msg => {
                            var label = new Gtk.Label (@"$(friend.name): $msg");
                            label.halign = Gtk.Align.START;
                            messages.append (label);
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
