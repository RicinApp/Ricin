[GtkTemplate (ui="/chat/tox/Ricin/chat-view.ui")]
class Ricin.ChatView : Gtk.Box {
    [GtkChild] Gtk.ListBox messages_list;
    [GtkChild] Gtk.Entry entry;
    [GtkChild] Gtk.Button send;

    private ListStore messages = new ListStore (typeof (Gtk.Label));

    public Tox.Friend fr;

    public ChatView (Tox.Friend fr) {
        this.fr = fr;
        this.messages_list.bind_model (this.messages, l => l as Gtk.Widget);

        fr.message.connect (msg => {
            var label = new Gtk.Label (@"$(fr.name): $msg");
            label.halign = Gtk.Align.START;
            messages.append (label);
        });

        send.clicked.connect (() => {
            var label = new Gtk.Label ("Me: " +entry.text);
            label.halign = Gtk.Align.START;
            messages.append (label);

            fr.send_message (entry.text);
            entry.text = "";
        });
    }
}
