public class Ricin.Ricin : Gtk.Application {
  public Ricin () {
    Object (application_id: "chat.tox.ricin",
            flags: ApplicationFlags.FLAGS_NONE); // TODO: handle open
  }

  public override void activate () {
    var provider = new Gtk.CssProvider ();
    provider.load_from_resource(@"$resource_base_path/themes/default.css");
    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
        provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    new ProfileChooser (this);
  }

  public static int main(string[] args) {
    return new Ricin ().run (args);
  }
}
