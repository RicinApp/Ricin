public class Ricin.Ricin : Gtk.Application {
  public Ricin () {
    Object (application_id: "chat.tox.ricin",
            flags: ApplicationFlags.FLAGS_NONE); // TODO: handle open
  }

  public override void activate () {
    new ProfileChooser (this);
  }

  public static int main(string[] args) {
    return new Ricin ().run (args);
  }
}
