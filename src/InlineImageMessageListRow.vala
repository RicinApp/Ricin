[GtkTemplate (ui="/chat/tox/ricin/ui/inline-image-message-list-row.ui")]
class Ricin.InlineImageMessageListRow : Gtk.ListBoxRow {
  [GtkChild] Gtk.Label label_name;
  [GtkChild] Gtk.Image image_inline;
  [GtkChild] Gtk.Label label_timestamp;
  [GtkChild] Gtk.Label label_image_info;
  [GtkChild] Gtk.Button button_save_inline;
  [GtkChild] Gtk.Image image_save_inline;

  private File image;
  private string image_name;

  public InlineImageMessageListRow (string name, string image_path, Gdk.Pixbuf image_inline, string timestamp) {
    this.image = File.new_for_path (image_path);

    this.label_name.set_markup (@"<b>$name</b>");
    this.image_inline.set_from_pixbuf (image_inline);
    this.label_timestamp.set_text (timestamp);


    FileInfo info = this.image.query_info ("standard::*", 0);
    this.image_name = info.get_display_name ();
    var image_size = info.get_size () / 1000;
    this.label_image_info.set_markup (@"$image_name ($image_size kb)");

    this.button_save_inline.clicked.connect (this.save_image);
  }

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

      this.button_save_inline.label = "Image saved!";
      this.image_save_inline.icon_name = "object-select-symbolic";
      this.button_save_inline.sensitive = false;
    }
  }

  private void popover_image () {

  }
}
