[GtkTemplate (ui="/chat/tox/Ricin/friend-list-row.ui")]
class Ricin.FriendListRow : Gtk.ListBoxRow {
    [GtkChild] Gtk.Image avatar;
    [GtkChild] Gtk.Label name;
    [GtkChild] Gtk.Label status;

    public FriendListRow (Tox.Friend fr) {
        fr.notify["name"].connect ((obj, prop) => name.label = fr.name);
        fr.notify["status-message"].connect ((obj, prop) => status.label = fr.status_message);
    }
}
