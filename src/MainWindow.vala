public class Ricin.MainWindow : Gtk.ApplicationWindow {
    Tox.Tox tox = new Tox.Tox ();

    public MainWindow (Ricin app) {
        Object (application: app);

        tox.notify["connected"].connect ((src, prop) => {
            print (@"Connected: $(tox.connected)\n");
        });

        tox.run_loop ();

        var label = new Gtk.Label (tox.id);
        label.selectable = true;
        this.add (label);

        this.show_all ();
    }
}
