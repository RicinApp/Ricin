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

  private File file;
  private uint32 file_id;
  private string file_name;
  private uint64 file_size;
  private uint position;

  // Managing the download
  private bool downloaded = false;
  private bool paused = false;

  private weak Tox.Friend sender;

  public signal void accept_file (bool response, uint32 file_id);

  public InlineFileMessageListRow (Tox.Friend sender, uint32 file_id, string username, string file_path, uint64 file_size, string timestamp) {
    this.sender = sender;
    this.file = File.new_for_path (file_path);
    this.file_id = file_id;
    this.file_name = this.file.get_basename ();
    this.file_size = file_size;

    this.label_name.set_markup (@"<b>$username</b>");
    this.label_timestamp.set_text (timestamp);
    this.label_file_name.set_text (this.file_name);
    this.label_file_size.set_text (@"($(this.file_size) kB)");

    this.sender.file_done.connect ((name, bytes, id) => {
      if (id != this.file_id)
        return;

      debug (@"File $(this.file_id) done!");

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
      //this.button_save.sensitive = false;
    });

    this.sender.file_received.connect (id => {
      if (id != this.file_id)
        return;

      this.downloaded = true;

      this.box_widget.get_style_context().add_class ("saved-file");
      this.button_save.set_size_request (65, 20);
      this.button_reject.visible = false;
      this.button_save.sensitive = false;
      this.image_save_inline.icon_name = "object-select-symbolic";
    });

    this.sender.file_paused.connect (id => {
      if (id != this.file_id)
        return;

      this.image_save_inline.icon_name = "media-playback-start-symbolic";
    });

    this.sender.file_resumed.connect (id => {
      if (id != this.file_id)
        return;

      this.image_save_inline.icon_name = "media-playback-pause-symbolic";
    });

    this.sender.file_canceled.connect (id => {
      if (id != this.file_id)
        return;

      this.file_id = -1; // File doesn't exists now, avoid issues.
      this.box_widget.get_style_context().add_class ("canceled-file");
      this.button_reject.set_size_request (65, 20);
      this.button_reject.sensitive = false;
      this.button_save.visible = false;
    });
  }

  [GtkCallback]
  private void save_file () {
    /**
    * TODO: Handle multiple state of the button using a less hacky way.
    **/

    if (this.downloaded == false) {
      debug ("Requested to save file");
      this.accept_file (true, this.file_id);
    } else {
      /**
      * TODO: Open the file in folder.
      **/

      return;
    }

    if (this.paused == false) {
      this.paused = !this.paused;
      this.image_save_inline.icon_name = "media-playback-pause-symbolic";
    } else {
      this.paused = !this.paused;
      this.image_save_inline.icon_name = "media-playback-start-symbolic";
    }


    /*
    string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
    File file_destination = File.new_for_path (downloads + this.file_name);

    int i = 0;
    string filename = this.file_name;
    while (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
      filename = @"$(++i)-$(this.file_name)";
    }

    file_destination = File.new_for_path (downloads + this.file_name);
    this.file.copy (file_destination, FileCopyFlags.NONE);

    if (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
      this.file.delete ();*/

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
    this.button_reject.set_size_request (65, 20);
    this.button_reject.sensitive = false;
    this.button_save.visible = false;
  }

  private void open_file () {

  }
}
