[GtkTemplate (ui="/chat/tox/ricin/ui/file-list-row.ui")]
class Ricin.FileListRow : Gtk.ListBoxRow {
  [GtkChild] public Gtk.Image image_author;
  [GtkChild] public Gtk.Label label_name;
  [GtkChild] Gtk.Label label_timestamp;

  [GtkChild] Gtk.Box box_widget;
  [GtkChild] Gtk.ProgressBar progress_file_percent;
  [GtkChild] public Gtk.Button button_save;
  [GtkChild] Gtk.Image image_save_inline;
  [GtkChild] public Gtk.Button button_reject;
  [GtkChild] Gtk.Image image_reject_inline;

  [GtkChild] Gtk.Box box_background;
  [GtkChild] Gtk.Image image_file_type;
  [GtkChild] Gtk.Label label_file_name;
  [GtkChild] Gtk.Label label_file_size;

  [GtkChild] Gtk.AspectFrame aspectframe_preview;
  [GtkChild] Gtk.Image image_preview;

  private File file;
  private uint32 file_id;
  private string file_name;
  private uint64 file_size;
  private uint64 raw_size;
  private uint position;

  // Managing the download
  private bool downloaded = false;
  private bool paused = false;

  private weak Tox.Tox handle;
  private weak Tox.Friend sender;
  private Settings settings;

  public signal void accept_file (bool response, uint32 file_id);

  public FileListRow (Tox.Tox handle, Tox.Friend sender, uint32 file_id, string username, string file_path, uint64 file_size, string timestamp, bool is_local_image = false, Gdk.Pixbuf? pixbuf = null, string? pixbuf_name = null) {
    this.handle = handle;
    this.sender = sender;
    this.settings = Settings.instance;

    this.file = File.new_for_path (file_path);
    this.file_id = file_id;
    this.raw_size = file_size;

    var size_req = new Gtk.Requisition ();
    this.get_preferred_size (out size_req, null);

    if (is_local_image) { // File is a local image.
      FileInfo info = this.file.query_info ("standard::*", 0);
      this.file_name = info.get_display_name ();
      this.file_size = info.get_size ();

      //var pix = new Gdk.Pixbuf.from_file_at_scale (this.file.get_path (), 400, 400, true);
      var pix = new Gdk.Pixbuf.from_file (this.file.get_path ());
      if (pix.width > size_req.width) {
        var pix_scaled = pix.scale_simple (size_req.width, 200, Gdk.InterpType.BILINEAR);
        this.image_preview.set_from_pixbuf (pix_scaled);
      } else {
        this.image_preview.set_from_pixbuf (pix);
      }

      this.image_preview.visible = true;
    } else if (pixbuf != null) { // File is an image.
      this.file_name = pixbuf_name;
      this.file_size = pixbuf.get_byte_length ();

      if (pixbuf.width > size_req.width) {
        var pix_scaled = pixbuf.scale_simple (size_req.width, 200, Gdk.InterpType.BILINEAR);
        this.image_preview.set_from_pixbuf (pix_scaled);
      } else {
        this.image_preview.set_from_pixbuf (pixbuf);
      }
      this.image_preview.visible = true;
    } else { // Normal file.
      this.file_name = this.file.get_basename ();
      this.file_size = file_size;
    }

    this.label_name.set_markup (@"<b>$username</b>");
    this.label_timestamp.set_text (timestamp);
    this.label_file_name.set_text (this.file_name);
    this.label_file_name.set_tooltip_text (this.file_name);
    this.label_file_size.set_text (Util.size_to_string (this.file_size));
    this.progress_file_percent.set_fraction (0.0);

    // If message is our (ugly&hacky way).
    if (this.handle.username == username) {
      this.handle.bind_property ("username", label_name, "label", BindingFlags.DEFAULT);
    }

    if (this.settings.compact_mode) {
      this.label_name.visible = false;
      this.image_author.visible = true;
    } else {
      this.label_name.visible = true;
      this.image_author.visible = false;
    }
    this.settings.notify["compact-mode"].connect (() => {
      if (this.settings.compact_mode) {
        this.label_name.visible = false;
        this.image_author.visible = true;
      } else {
        this.label_name.visible = true;
        this.image_author.visible = false;
      }
    });

    if (this.sender == null) {
      this.image_author.set_from_pixbuf (Util.pubkey_to_image (this.handle.pubkey, 24, 24));
      this.image_author.pixbuf = this.image_author.pixbuf.scale_simple (24, 24, Gdk.InterpType.BILINEAR);
      this.image_author.set_pixel_size (24);
      this.image_author.set_size_request (24, 24);

      this.handle.notify["avatar"].connect (() => {
        this.image_author.pixbuf = this.handle.avatar.scale_simple (24, 24, Gdk.InterpType.BILINEAR);;
      });

      this.image_author.set_tooltip_text (this.handle.username);
      this.handle.notify["username"].connect (() => {
        this.image_author.set_tooltip_text (this.handle.username);
      });
    } else {
      this.image_author.set_from_pixbuf (Util.pubkey_to_image (this.sender.pubkey, 24, 24));
      this.image_author.pixbuf = this.image_author.pixbuf.scale_simple (24, 24, Gdk.InterpType.BILINEAR);
      this.image_author.set_pixel_size (24);
      this.image_author.set_size_request (24, 24);

      this.image_author.set_tooltip_text (this.sender.name);
      this.sender.avatar.connect (px => {
        this.image_author.pixbuf = px.scale_simple (24, 24, Gdk.InterpType.BILINEAR);;
      });
    }

    this.sender.file_done.connect ((name, bytes, id) => {
      if (id != this.file_id) {
        return;
      }

      debug (@"File $(this.file_id) done!");

      // Set the progressbar to 100% and hide it.
      this.progress_file_percent.set_fraction (1.0);
      this.progress_file_percent.visible = false;

      string downloads = this.settings.default_save_path;
      File file_destination = File.new_for_path (@"$downloads/$(this.file_name)");
      if (FileUtils.test (file_destination.get_path (), FileTest.EXISTS)) {
        Rand rnd = new Rand.with_seed ((uint32)new DateTime.now_local ().hash ());
        uint32 rnd_id = rnd.next_int ();
        string filename = @"$rnd_id-$(this.file_name)";
        file_destination = File.new_for_path (downloads.concat ("/", filename));
        FileUtils.set_data (file_destination.get_path (), bytes.get_data ());
        this.file = file_destination;
      } else {
        file_destination = File.new_for_path (downloads.concat ("/", this.file_name));
        FileUtils.set_data (file_destination.get_path (), bytes.get_data ());
        this.file = file_destination;
      }

      this.set_redraw_on_allocate (true);
      Gdk.Pixbuf p = new Gdk.Pixbuf.from_file (this.file.get_path ());
      if (p.width > size_req.width) {
        var pix_scaled = p.scale_simple (size_req.width, 200, Gdk.InterpType.BILINEAR);
        this.image_preview.set_from_pixbuf (pix_scaled);
      } else {
        this.image_preview.set_from_pixbuf (p);
      }

      this.image_preview.visible = true;
      this.changed ();
      this.set_size_request (-1, -1);

      this.downloaded = true;
      this.button_save.get_style_context ().add_class ("saved-file");
      this.button_save.set_size_request (65, 20);
      this.button_reject.visible = false;
      this.image_save_inline.icon_name = "folder-open-symbolic";
      this.button_save.sensitive = true;
    });

    this.sender.file_received.connect (id => {
      if (id != this.file_id) {
        return;
      }

      this.downloaded = true;
      this.progress_file_percent.visible = false;
      this.button_save.get_style_context ().add_class ("saved-file");
      this.button_save.set_size_request (65, 20);
      this.button_reject.visible = false;
      this.button_save.sensitive = true;
      //this.label_foreground.width_request = -1;
      this.image_save_inline.icon_name = "object-select-symbolic";
      this.button_save.set_tooltip_text ("File saved. Click to open");
    });

    this.sender.file_progress.connect ((id, position) => {
      if (id != this.file_id) {
        return;
      }

      uint64 size_total = this.raw_size;
      uint64 size_received = position;
      double percent = size_received / (double)size_total;
      this.progress_file_percent.set_fraction (percent);

      if (this.progress_file_percent.visible == false) {
        this.progress_file_percent.visible = true;
      }
    });

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
      this.button_save.get_style_context().add_class ("canceled-file");
      this.button_reject.set_size_request (65, 20);
      this.button_reject.sensitive = false;
      //this.label_foreground.width_request = -1;
      this.button_save.visible = false;
      this.progress_file_percent.visible = false;
      this.button_reject.set_tooltip_text ("Canceled");
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
      this.progress_file_percent.visible = true;
      /*this.box_widget.get_style_context().add_class ("progress-bg");
      this.label_foreground.get_style_context().add_class ("progress-fg");
      this.progress_transfers.visible = true;*/
    } else {
      /**
      * TODO: Open the file in folder.
      **/
      try {
        AppInfo.launch_default_for_uri (this.file.get_uri (), null);
      } catch (Error e) {
        debug (@"Cannot open $(this.file_name): $(e.message)");
      }
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
    this.button_save.get_style_context().add_class ("canceled-file");

    //this.button_reject.label = "Canceled";
    /*this.progress_transfers.visible = false;*/
    this.button_reject.set_size_request (65, 20);
    this.button_reject.sensitive = false;
    this.button_save.visible = false;
    this.progress_file_percent.visible = false;
  }

  private void open_file () {

  }
}
