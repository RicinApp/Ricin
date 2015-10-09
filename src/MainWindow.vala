public class Ricin.MainWindow : Gtk.ApplicationWindow {
	public MainWindow (Ricin app) {
		app.add_window (this);
		this.show_all ();
	}
}
