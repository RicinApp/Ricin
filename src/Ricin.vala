public class Ricin.Ricin : Gtk.Application {
  private string default_theme = "dark"; // Hardcoded until we have proper settings.

  public Ricin () {
    Object (application_id: "chat.tox.ricin",
            flags: ApplicationFlags.FLAGS_NONE); // TODO: handle open
  }

  public override void activate () {
    // Load the default css.
    var provider = new Gtk.CssProvider ();
    provider.load_from_resource(@"$resource_base_path/themes/$(this.default_theme).css");
    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
        provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    // Launch the notification system.
    Notify.init ("Ricin");

    // Show the login window.
    new ProfileChooser (this);
  }

  public static int main(string[] args) {
    return new Ricin ().run (args);
  }
}
