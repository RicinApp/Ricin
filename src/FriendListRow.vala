[GtkTemplate (ui="/chat/tox/Ricin/friend-list-row.ui")]
class Ricin.FriendListRow : Gtk.ListBoxRow {
    [GtkChild] Gtk.Image avatar;
    [GtkChild] Gtk.Label name;
    [GtkChild] Gtk.Label status;
}
