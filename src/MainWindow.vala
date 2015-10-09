public class Ricin.MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Ricin app) {
        Object (application: app);
        this.show_all ();
    }
}
