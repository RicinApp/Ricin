[GtkTemplate (ui="/chat/tox/ricin/ui/inline-image-message-list-row.ui")]
class Ricin.InlineImageMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Image image_inline;
  [GtkChild] Gtk.Label label_timestamp;
  [GtkChild] Gtk.Label label_image_name;
  [GtkChild] Gtk.Label label_image_size;
  [GtkChild] public Gtk.Button button_save_inline;
  [GtkChild] Gtk.Image image_save_inline;

  private File image;
  private string image_name;
  private uint32 image_id;

  private uint position;
  private weak Tox.Tox handle;
  private weak Tox.Friend sender;

  public signal void accept_image (bool response, uint32 file_id);

  public InlineImageMessageListRow (Tox.Tox handle, Tox.Friend sender, uint32 file_id, string name, string image_path, string timestamp, bool? is_local) {
    this.handle = handle;
    this.image = File.new_for_path (image_path);
    this.image_id = file_id;

    // Ask for image downloading.
    this.accept_image (true, this.image_id);

    this.label_name.set_markup (@"<b>$name</b>");
    this.label_timestamp.set_text (timestamp);

    // If message is our (ugly&hacky way).
    if (this.handle.username == name) {
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
    }

    if (is_local) {
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (this.image.get_path (), 400, 250, true);
      this.image_inline.set_from_pixbuf (pixbuf);
      FileInfo info = this.image.query_info ("standard::*", 0);
      this.image_name = info.get_display_name ();
      var image_size = info.get_size () / 1000;
      this.label_image_name.set_text (@"$(this.image_name)");
      this.label_image_size.set_text (Util.size_to_string (image_size));
    }

    this.sender.file_done.connect ((name, bytes, id) => {
      if (id != this.image_id) {
        return;
      }

      debug (@"Image $(this.image_id) done!");

      //string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
      File file_destination = File.new_for_path (this.image.get_path ());

      int i = 0;
      string filename = this.image_name;
      while (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
        filename = @"$(++i)-$(this.image_name)";
      }

      file_destination = File.new_for_path (@"/tmp/$filename");
      FileUtils.set_data (file_destination.get_path (), bytes.get_data ());
      //this.file.copy (file_destination, FileCopyFlags.NONE);

      if (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
        this.image = file_destination;
        var pixbuf = new Gdk.Pixbuf.from_file_at_scale (this.image.get_path (), 400, 250, true);
        this.image_inline.set_from_pixbuf (pixbuf);
        FileInfo info = this.image.query_info ("standard::*", 0);
        this.image_name = info.get_display_name ();
        var image_size = info.get_size () / 1000;
        this.label_image_name.set_text (@"$filename");
        this.label_image_size.set_text (Util.size_to_string (image_size));
      }
    });
  }

  [GtkCallback]
  private void save_image () {
    string downloads = Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + "/";
    File image_destination = File.new_for_path (downloads + this.image_name);

    int i = 0;
    string filename = this.image_name;
    while (FileUtils.test (image_destination.get_path (), FileTest.EXISTS)) {
      filename = @"$(++i)-$(this.image_name)";
    }

    image_destination = File.new_for_path (downloads + this.image_name);
    this.image.copy (image_destination, FileCopyFlags.NONE);

    if (FileUtils.test (image_destination.get_path (), FileTest.EXISTS)) {
      this.image.delete ();

      this.button_save_inline.label = _("Image saved!");
      this.image_save_inline.icon_name = "object-select-symbolic";
      this.button_save_inline.sensitive = false;
    }
  }

  private void popover_image () {

  }
}
