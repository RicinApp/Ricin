public class Ricin.Ricin : Gtk.Application {
  public Ricin () {
    Object (application_id: "chat.tox.ricin",
            flags: ApplicationFlags.FLAGS_NONE);
  }

  public override void activate () {
    new ProfileChooserWindow (this);
    Gtk.main ();
  }

  public static int main(string[] args) {
    return new Ricin ().run (args);
  }
}
