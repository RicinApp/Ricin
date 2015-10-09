class Ricin.ProfileChooser  : Gtk.Window {
	public ProfileChooser () {
		var dir = Environment.get_home_dir () + "/.config/tox/";
		var configdir = File.new_for_path (dir);
		string[] files = {};
		if (!configdir.query_exists ()) {
			configdir.make_directory ();
		} else {
			var enumerator = configdir.enumerate_children (FileAttribute.STANDARD_NAME, 0);
			FileInfo info;
			while ((info = enumerator.next_file ()) != null) {
				if (info.get_name ().has_suffix (".tox"))
					files += dir + info.get_name ();
			}
		}
		files += "New Profile";

		var list = new Gtk.ListBox ();
		list.selection_mode = Gtk.SelectionMode.NONE;

		foreach (string profile in files) {
			var row = new Gtk.ListBoxRow ();
			var label = new Gtk.Label (profile);
			label.margin = 20;
			row.add (label);
			list.add (row);
		}

		this.add (list);

		this.show_all ();
	}
}
