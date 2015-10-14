[GtkTemplate (ui="/chat/tox/Ricin/main-window.ui")]
public class Ricin.MainWindow : Gtk.ApplicationWindow {
  [GtkChild] Gtk.Entry entry_name;
  [GtkChild] Gtk.Entry entry_status;
  [GtkChild] Gtk.ListBox friendlist;
  [GtkChild] Gtk.Entry entry_friend_id;
  [GtkChild] Gtk.Button button_add_friend;
  [GtkChild] Gtk.Image connection_image;
  [GtkChild] Gtk.Label toxid;
  [GtkChild] Gtk.Stack chat_stack;

  private ListStore friends = new ListStore (typeof (Tox.Friend));

  Tox.Tox tox;

  public MainWindow (Ricin app) {
    Object (application: app);

    var options = Tox.Options.create ();
    options.ipv6_enabled = true;
    options.udp_enabled = true;
    this.tox = new Tox.Tox (options);

    this.toxid.label += this.tox.id;

    this.friendlist.bind_model (this.friends, fr => new FriendListRow (fr as Tox.Friend));
    this.friendlist.row_activated.connect ((lb, row) => {
      var fr = (row as FriendListRow).fr;
      foreach (var view in chat_stack.get_children ()) {
        if ((view as ChatView).fr == fr) {
          chat_stack.set_visible_child (view);
          break;
        }
      }
    });

    this.entry_name.key_press_event.connect ((event) => {
      if (event.keyval == Gdk.Key.Return) {
        this.tox.username = this.entry_name.text;
      }
      return false;
    });

    this.entry_name.bind_property ("text", this.tox, "username", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
    this.entry_status.bind_property ("text", this.tox, "status_message", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

    this.entry_status.key_press_event.connect ((event) => {
      if (event.keyval == Gdk.Key.Return) {
        this.tox.status_message = this.entry_status.text;
      }
      return false;
    });

    this.button_add_friend.clicked.connect (() => {
      var tox_id = this.entry_friend_id.text;
      var error_message = "";

      if (tox_id.length == 76) {
        var friend = tox.add_friend (tox_id, "Hello, I'm " + this.tox.username + ". Currently using Ricin, please add this friend request.");
        this.entry_friend_id.set_text (""); // Clear the entry after adding a friend.
        return;
        //this.friends.append (friend);
      } else if (tox_id.index_of ("@") != -1) {
        error_message = "Ricin doesn't supports ToxDNS yet.";
      } else {
        error_message = "Invalid ToxID.";
      }

      Gtk.MessageDialog msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, error_message);
      msg.response.connect (response => msg.destroy ());
      msg.show ();
    });

    this.tox.notify["connected"].connect ((src, prop) => {
      this.connection_image.icon_name = this.tox.connected ? "gtk-yes" : "gtk-no";
    });

    this.tox.friend_request.connect ((id, message) => {
      var dialog = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "Friend request from:");
      dialog.secondary_text = id + "\n\n\"" + message + "\"";
      dialog.add_buttons ("Accept", Gtk.ResponseType.ACCEPT, "Reject", Gtk.ResponseType.REJECT);
      dialog.response.connect (response => {
        if (response == Gtk.ResponseType.ACCEPT) {
          var friend = tox.accept_friend_request (id);
          if (friend != null) {
            friends.append (friend);
            chat_stack.add_named (new ChatView (this.tox, friend), friend.name);
          }
        }
        dialog.destroy ();
      });
      dialog.show ();
    });

    this.tox.run_loop ();

    this.show_all ();
  }
}
