[GtkTemplate (ui="/chat/tox/ricin/ui/inline-file-message-list-row.ui")]
class Ricin.InlineFileMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Image image_file_type;
  [GtkChild] Gtk.Label label_timestamp;
  [GtkChild] Gtk.Box box_widget;
  [GtkChild] Gtk.Label label_file_name;
  [GtkChild] Gtk.Label label_file_size;
  [GtkChild] public Gtk.Button button_save;
  [GtkChild] public Gtk.Button button_reject;
  [GtkChild] Gtk.Image image_save_inline;
  [GtkChild] Gtk.Image image_reject_inline;
  [GtkChild] Gtk.Box box_background;
  [GtkChild] Gtk.Label label_foreground;
  [GtkChild] Gtk.ProgressBar progress_file_percent;

  private File file;
  private uint32 file_id;
  private string file_name;
  private uint64 file_size;
  private uint position;

  // Managing the download
  private bool downloaded = false;
  private bool paused = false;

  private weak Tox.Tox handle;
  private weak Tox.Friend sender;

  public signal void accept_file (bool response, uint32 file_id);

  public InlineFileMessageListRow (Tox.Tox handle, Tox.Friend sender, uint32 file_id, string username, string file_path, uint64 file_size, string timestamp) {
    this.handle = handle;
    this.sender = sender;
    this.file = File.new_for_path (file_path);
    this.file_id = file_id;
    this.file_name = this.file.get_basename ();
    this.file_size = file_size;

    this.label_name.set_markup (@"<b>$username</b>");
    this.label_timestamp.set_text (timestamp);
    this.label_file_name.set_text (this.file_name);
    this.label_file_size.set_text (Util.size_to_string (this.file_size));
    this.progress_file_percent.set_fraction (0.0);

    // If message is our (ugly&hacky way).
    if (this.handle.username == username) {
      debug ("Keeping names in sync !");
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
    }

    this.sender.file_done.connect ((name, bytes, id) => {
      if (id != this.file_id) {
        return;
      }

      debug (@"File $(this.file_id) done!");

      // Set the progressbar to 100% and hide it.
      this.progress_file_percent.set_fraction (1.0);
      this.progress_file_percent.visible = false;

      string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
      File file_destination = File.new_for_path (downloads + this.file_name);

      int i = 0;
      string filename = this.file_name;
      while (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
        filename = @"$(++i)-$(this.file_name)";
      }

      file_destination = File.new_for_path (downloads + filename);
      FileUtils.set_data (file_destination.get_path (), bytes.get_data ());
      //this.file.copy (file_destination, FileCopyFlags.NONE);

      /*if (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
        this.file.delete ();
      }*/

      this.downloaded = true;
      this.box_widget.get_style_context().add_class ("saved-file");
      this.button_save.set_size_request (65, 20);
      this.button_reject.visible = false;
      this.image_save_inline.icon_name = "folder-open-symbolic";
    });

    this.sender.file_received.connect (id => {
      if (id != this.file_id) {
        return;
      }

      this.downloaded = true;

      this.box_widget.get_style_context().add_class ("saved-file");
      this.button_save.set_size_request (65, 20);
      this.button_reject.visible = false;
      this.button_save.sensitive = false;
      //this.label_foreground.width_request = -1;
      this.image_save_inline.icon_name = "object-select-symbolic";
    });

    /*this.sender.file_progress.connect ((id, position) => {
      if (id != this.file_id)
        return;

      var percent = (int)position / this.file_size;
      debug (@"File $id - Size: $(this.file_size) - Position: $position");
      debug (@"Progress percent: $percent");
      //debug (@"Received %s% of file %s", percent, id);
      this.progressbar_buffer.set_fraction ((int) percent);

      this.progressbar_buffer.notify["fraction"].connect((o, p) => {
        this.label_foreground.width_request = (int) this.progressbar_buffer.fraction * 100;
      });
    });*/

    this.sender.file_paused.connect (id => {
      if (id != this.file_id) {
        return;
      }

      this.image_save_inline.icon_name = "media-playback-start-symbolic";
    });

    this.sender.file_resumed.connect (id => {
      if (id != this.file_id) {
        return;
      }

      this.image_save_inline.icon_name = "media-playback-pause-symbolic";
    });

    this.sender.file_canceled.connect (id => {
      if (id != this.file_id) {
        return;
      }

      this.file_id = -1; // File doesn't exists now, avoid issues.
      this.box_widget.get_style_context().add_class ("canceled-file");
      this.button_reject.set_size_request (65, 20);
      this.button_reject.sensitive = false;
      //this.label_foreground.width_request = -1;
      this.button_save.visible = false;
      this.progress_file_percent.visible = false;
    });

    /*this.sender.file_progress.connect ((id, position) => {
      if (id != this.file_id)
        return;

      debug (@"File Progress: id: $id - position: $position");
    });*/
  }

  [GtkCallback]
  private void save_file () {
    /**
    * TODO: Handle multiple state of the button using a less hacky way.
    **/
    if (this.downloaded == false) {
      debug ("Requested to save file");
      this.accept_file (true, this.file_id);
      /*this.box_widget.get_style_context().add_class ("progress-bg");
      this.label_foreground.get_style_context().add_class ("progress-fg");
      this.progress_transfers.visible = true;*/
    } else {
      /**
      * TODO: Open the file in folder.
      **/

      return;
    }

    if (this.paused == false) {
      this.paused = !this.paused;
      this.image_save_inline.icon_name = "media-playback-pause-symbolic";
      //this.label_foreground.width_request = this.label_foreground.width_request + 10;
    } else {
      this.paused = !this.paused;
      this.image_save_inline.icon_name = "media-playback-start-symbolic";
    }

    /**
    * TODO: Change box_widget background to progress.
    * NOTE: Use a Gtk.Overlay and change it's background color + update width
    *       of the overlay related to the file progress.
    **/
    /*this.box_widget.get_style_context().add_class ("saved-file");
    this.button_save.set_size_request (65, 20);
    this.button_save.sensitive = false;
    this.button_reject.visible = false;*/
  }

  [GtkCallback]
  private void reject_file () {
    this.accept_file (false, this.file_id);
    this.file_id = -1; // File doesn't exists now, avoid issues.

    /**
    * TODO: Change box_widget background to red.
    * NOTE: Use the .canceled-file css class defined in default.css
    **/
    this.box_widget.get_style_context().add_class ("canceled-file");

    //this.button_reject.label = "Canceled";
    /*this.progress_transfers.visible = false;*/
    this.button_reject.set_size_request (65, 20);
    this.button_reject.sensitive = false;
    this.button_save.visible = false;
  }

  private void open_file () {

  }
}
