[GtkTemplate (ui="/chat/tox/ricin/ui/welcome-view.ui")]
class Ricin.WelcomeView : Gtk.Box {
  // Notebook buttons
  [GtkChild] Gtk.Box box_tab_buttons;
  [GtkChild] Gtk.Label label_home_notice;
  [GtkChild] Gtk.Button button_home_settings;

  private weak Tox.Tox handle;

  public WelcomeView (Tox.Tox handle) {
    this.handle = handle;
  }

  [GtkCallback]
  private void show_settings () {
    var main_window = ((MainWindow) this.get_toplevel ());
    main_window.display_settings ();
  }
}
