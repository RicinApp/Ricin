[GtkTemplate (ui="/chat/tox/Ricin/main-window.ui")]
public class Ricin.MainWindow : Gtk.ApplicationWindow {
  [GtkChild] Gtk.Button avatar_button;
  [GtkChild] Gtk.Image avatar_image;
  [GtkChild] Gtk.Entry entry_name;
  [GtkChild] Gtk.Entry entry_status;
  [GtkChild] Gtk.Button button_user_status;
  [GtkChild] Gtk.Image image_user_status;

  [GtkChild] Gtk.ListBox friendlist;
  // [GtkChild] Gtk.Label toxid;
  [GtkChild] public Gtk.Stack chat_stack;
  [GtkChild] public Gtk.Button button_add_friend_show;
  [GtkChild] public Gtk.Button button_settings;

  // Add friend revealer.
  [GtkChild] public Gtk.Revealer add_friend;
  [GtkChild] public Gtk.Entry entry_friend_id;
  [GtkChild] Gtk.TextView entry_friend_message;
  [GtkChild] Gtk.Label label_add_error;
  [GtkChild] Gtk.Button button_add_friend;
  [GtkChild] Gtk.Button button_cancel_add;

  // System notify.
  [GtkChild] public Gtk.Revealer revealer_system_notify;
  [GtkChild] public Gtk.Label label_system_notify;

  private ListStore friends = new ListStore (typeof (Tox.Friend));
  public Tox.Tox tox;
  private File avatar_cached;

  public signal void notify_message (string message, int timeout = 5000);

  public MainWindow (Gtk.Application app, string profile) {
    Object (application: app);

    var opts = Tox.Options.create ();
    opts.ipv6_enabled = true;
    opts.udp_enabled = true;

    try {
      this.tox = new Tox.Tox (opts, profile);
    } catch (Tox.ErrNew error) {
      warning ("Tox init failed: %s", error.message);
      this.destroy ();
      var error_dialog = new Gtk.MessageDialog (null,
          Gtk.DialogFlags.MODAL,
          Gtk.MessageType.WARNING,
          Gtk.ButtonsType.OK,
          "Can't load the profile");
      error_dialog.secondary_use_markup = true;
      error_dialog.format_secondary_markup (@"<span color=\"#e74c3c\">$(error.message)</span>");
      error_dialog.response.connect (response_id => {
        error_dialog.destroy ();
      });
      error_dialog.show ();
      return;
    }

    //this.toxid.label += this.tox.id;
    this.avatar_cached = File.new_for_path (Tox.profile_dir () + "avatars/" + this.tox.pubkey + ".png");
    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (this.avatar_cached.get_path (), 46, 46, true);
    this.avatar_image.pixbuf = pixbuf;

    this.entry_name.set_text (this.tox.username);
    this.entry_status.set_text (this.tox.status_message);

    this.button_add_friend_show.clicked.connect (() => {
      this.show_add_friend_popover ();
    });

    this.button_settings.clicked.connect (() => {
      var settings_view = this.chat_stack.get_child_by_name ("settings");

      if (settings_view != null) {
        this.chat_stack.set_visible_child (settings_view);
      } else {
        var view = new SettingsView (this.tox);
        this.chat_stack.add_named (view, "settings");
        this.chat_stack.set_visible_child (view);
      }
    });

    this.button_add_friend.clicked.connect (() => {
      var tox_id = this.entry_friend_id.get_text ();
      var message = this.entry_friend_message.buffer.text;
      var error_message = "";
      this.label_add_error.use_markup = true;
      this.label_add_error.use_markup = true;
      this.label_add_error.halign = Gtk.Align.CENTER;
      this.label_add_error.wrap_mode = Pango.WrapMode.CHAR;
      this.label_add_error.selectable = true;
      this.label_add_error.set_line_wrap (true);

      if (tox_id.length == ToxCore.ADDRESS_SIZE*2) { // bytes -> chars
        try {
          var friend = tox.add_friend (tox_id, message);
          this.tox.save_data (); // Needed to avoid breaking profiles if app crash.
          this.entry_friend_id.set_text (""); // Clear the entry after adding a friend.
          this.add_friend.reveal_child = false;
          this.label_add_error.set_text ("Add a friend");
          this.button_add_friend_show.visible = true;
          return;
        } catch (Tox.ErrFriendAdd error) {
          debug ("Adding friend failed: %s", error.message);
          error_message = error.message;
        }
      } else if (tox_id.index_of ("@") != -1) {
        error_message = "Ricin doesn't supports ToxDNS yet.";
      } else if (tox_id.strip () == "") {
        error_message = "ToxID can't be empty.";
      } else {
        error_message = "ToxID is invalid.";
      }

      if (error_message.strip () != "") {
        this.label_add_error.set_markup (@"<span color=\"#e74c3c\">$error_message</span>");
        return;
      }

      this.add_friend.reveal_child = false;
      this.button_add_friend_show.visible = true;
    });

    this.button_cancel_add.clicked.connect (() => {
      this.add_friend.reveal_child = false;
      this.label_add_error.set_text ("Add a friend");
      this.button_add_friend_show.visible = true;
    });

    this.friendlist.bind_model (this.friends, fr => new FriendListRow (fr as Tox.Friend));
    this.friendlist.row_activated.connect ((lb, row) => {
      var friend = (row as FriendListRow).fr;
      var view_name = "chat-%s".printf (friend.pubkey);
      var chat_view = this.chat_stack.get_child_by_name (view_name);
      debug ("ChatView name: %s", view_name);

      if (chat_view != null) {
        this.chat_stack.set_visible_child (chat_view);
        //chat_view.entry.grab_focus ();
      }
    });

    this.entry_name.activate.connect (() => this.tox.username = Util.escape_html (this.entry_name.text));
    this.entry_status.bind_property ("text", this.tox, "status_message", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

    this.button_user_status.clicked.connect (() => {
      var status = this.tox.status;
      switch (status) {
        case Tox.UserStatus.ONLINE:
          // Set status to away.
          this.tox.status = Tox.UserStatus.AWAY;
          this.image_user_status.icon_name = "user-away";
          break;
        case Tox.UserStatus.AWAY:
          // Set status to busy.
          this.tox.status = Tox.UserStatus.BUSY;
          this.image_user_status.icon_name = "user-busy";
          break;
        case Tox.UserStatus.BUSY:
          // Set status to online.
          this.tox.status = Tox.UserStatus.ONLINE;
          this.image_user_status.icon_name = "user-available";
          break;
        default:
          this.image_user_status.icon_name = "user-offline";
          break;
      }
    });

    this.tox.notify["connected"].connect ((src, prop) => {
      this.image_user_status.icon_name = this.tox.connected ? "user-available" : "user-offline";
      this.button_user_status.sensitive = this.tox.connected;
    });

    this.tox.friend_request.connect ((id, message) => {
      var dialog = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "Friend request from:");
      dialog.secondary_text = @"$id\n\n$message";
      dialog.add_buttons ("Accept", Gtk.ResponseType.ACCEPT, "Reject", Gtk.ResponseType.REJECT);
      dialog.response.connect (response => {
        if (response == Gtk.ResponseType.ACCEPT) {
          var friend = tox.accept_friend_request (id);
          if (friend != null) {
            this.tox.save_data (); // Needed to avoid breaking profiles if app crash.

            friends.append (friend);
            var view_name = "chat-%s".printf (friend.pubkey);
            chat_stack.add_named (new ChatView (this.tox, friend), view_name);

            var info_message = "The friend request has been accepted. Please wait the contact to appears online.";
            this.notify_message (@"<span color=\"#27ae60\">$info_message</span>", 5000);
          }
        }
        dialog.destroy ();
      });
      dialog.show ();
    });

    this.tox.friend_online.connect ((friend) => {
      if (friend != null) {
        friends.append (friend);
        var view_name = "chat-%s".printf (friend.pubkey);
        chat_stack.add_named (new ChatView (this.tox, friend), view_name);

        // Send our avatar.
        this.tox.send_avatar (this.avatar_cached.get_path (), friend);
      }
    });

    this.notify_message.connect ((message, timeout) =>  {
      this.label_system_notify.use_markup = true;
      this.label_system_notify.set_markup (message);
      this.revealer_system_notify.reveal_child = true;
      Timeout.add (timeout, () => {
        this.revealer_system_notify.reveal_child = false;
        return Source.REMOVE;
      });
    });

    this.avatar_button.clicked.connect (e => {
      var chooser = new Gtk.FileChooserDialog ("Select your avatar",
          this,
          Gtk.FileChooserAction.OPEN,
          "_Cancel", Gtk.ResponseType.CANCEL,
          "_Open", Gtk.ResponseType.ACCEPT);
      var filter = new Gtk.FileFilter ();
      filter.add_custom (Gtk.FileFilterFlags.MIME_TYPE, info => {
        var mime = info.mime_type;
        return mime.has_prefix ("image/") && mime != "image/gif";
      });
      chooser.filter = filter;
      if (chooser.run () == Gtk.ResponseType.ACCEPT) {
        string filename = chooser.get_filename ();
        this.tox.send_avatar (filename);

        var pixel = new Gdk.Pixbuf.from_file_at_scale (filename, 46, 46, true);
        this.avatar_image.pixbuf = pixel;

        // Copy avatar in ~/.config/tox/avatars/
        try {
          File av = File.new_for_path (filename);
          av.copy (this.avatar_cached, FileCopyFlags.OVERWRITE);
        } catch (Error err) {
          warning ("Cannot save the avatar in cache: %s", err.message);
        }
      }

      chooser.close ();
    });

    this.delete_event.connect ((event) => {
      this.tox.save_data ();
      return false;
    });

    this.tox.run_loop ();
    this.show_all ();
  }

  public void show_add_friend_popover (string toxid = "", string message = "") {
    var friend_message = "";

    if (message.strip () == "") {
      friend_message = "Hello! It's " + this.tox.username + ", let's be friends.";
    }

    this.entry_friend_id.set_text (toxid);
    this.entry_friend_message.buffer.text = friend_message;
    this.button_add_friend_show.visible = false;
    this.add_friend.reveal_child = true;
  }
}
