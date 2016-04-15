class Settings : Object {
  /**
  * Private members, used only by this class.
  **/
  private string profile;

  /**
  * Public const members, used to read & write JSON file.
  **/
  public const string HAS_TOXME_KEY            = "has-toxme";
  public const string TOXME_ID_KEY             = "toxme-id";
  public const string TOXME_SERVER_KEY         = "toxme-server";
  public const string TOXME_BIOGRAPHY_KEY      = "toxme-biography";
  public const string TOXME_PASSWORD_KEY       = "toxme-password";
  public const string LAST_PROFILE_KEY         = "last-profile";
  public const string NETWORK_UDP_KEY          = "network-udp";
  public const string NETWORK_IPV6_KEY         = "network-ipv6";
  public const string ENABLE_PROXY_KEY         = "enable-proxy";
  public const string PROXY_HOST_KEY           = "proxy-host";
  public const string PROXY_PORT_KEY           = "proxy-port";
  public const string ENABLE_CUSTOM_THEMES_KEY = "enable-custom-themes";
  public const string SELECTED_THEME_KEY       = "selected-theme";
  public const string SELECTED_LANGUAGE_KEY    = "selected-language";
  public const string SHOW_STATUS_CHANGES_KEY  = "show-status-changes";
  public const string SHOW_ALL_FRIENDS_KEY     = "show-all-friends";
  public const string SHOW_UNREAD_MESSAGES_KEY = "show-unread-messages-notice";
  public const string SHOW_TYPING_STATUS_KEY   = "show-typing-status";
  public const string SEND_TYPING_STATUS_KEY   = "send-typing-status";
  public const string CONTACTLIST_WIDTH_KEY    = "contactlist-width";
  public const string ENABLE_TRAY_KEY          = "enable-tray";
  public const string ENABLE_NOTIFY_KEY        = "enable-notify";
  public const string ENABLE_NOTIFY_SOUNDS_KEY = "enable-notify-sounds";
  public const string DEFAULT_SAVE_PATH_KEY    = "default-save-path";

  /**
  * Public members, can be get/set.
  **/
  public bool has_toxme            { get; set; default = false; }
  public string toxme_id           { get; set; default = null; }
  public string toxme_server       { get; set; default = null; }
  public string toxme_biography    { get; set; default = null; }
  public string toxme_password     { get; set; default = null; }
  public string last_profile       { get; set; default = ""; }
  public bool network_udp          { get; set; default = true; }
  public bool network_ipv6         { get; set; default = true; }
  public bool enable_proxy         { get; set; default = false; }
  public string proxy_host         { get; set; default = "127.0.0.1"; }
  public int proxy_port            { get; set; default = 9050; }
  public bool enable_custom_themes { get; set; default = true; }
  public string selected_theme     { get; set; default = "dark"; }
  public string selected_language  { get; set; default = "en_US"; }
  public bool show_status_changes  { get; set; default = true; }
  public bool show_all_friends     { get; set; default = false; }
  public bool show_unread_messages { get; set; default = false; }
  public bool show_typing_status   { get; set; default = true; }
  public bool send_typing_status   { get; set; default = true; }
  public int contactlist_width     { get; set; default = 265; }
  public bool enable_tray          { get; set; default = true; }
  public bool enable_notify        { get; set; default = true; }
  public bool enable_notify_sounds { get; set; default = true; }
  public string default_save_path  { get; set; default = ""; }

  private static Settings? _instance;
  public static Settings instance {
    get {
      if (_instance == null) {
        string settings_file = "%s/ricin.json".printf (Tox.profile_dir ());
        _instance = new Settings(settings_file);
      }
      return _instance;
    }
    private set {
      _instance = value;
    }
  }

  public Settings (string profile) {
    debug (@"Started SettingsManager...");
    this.profile = profile;

    this.load_settings ();
    this.notify.connect ((opt, props) => {
      this.save_settings ();
    });
  }

  public void load_settings () {
    Json.Node node;
    try {
      Json.Parser parser = new Json.Parser ();
      parser.load_from_file (this.profile);
      node = parser.get_root ();

      Settings? settings = Json.gobject_deserialize (typeof (Settings), node) as Settings;
      if (settings != null) {
        this.has_toxme            = settings.has_toxme;
        this.toxme_id             = settings.toxme_id;
        this.toxme_server         = settings.toxme_server;
        this.toxme_biography      = settings.toxme_biography;
        this.toxme_password       = settings.toxme_password;
        this.last_profile         = settings.last_profile;
        this.network_udp          = settings.network_udp;
        this.network_ipv6         = settings.network_ipv6;
        this.enable_proxy         = settings.enable_proxy;
        this.proxy_host           = settings.proxy_host;
        this.proxy_port           = settings.proxy_port;
        this.enable_custom_themes = settings.enable_custom_themes;
        this.selected_theme       = settings.selected_theme;
        this.selected_language    = settings.selected_language;
        this.show_status_changes  = settings.show_status_changes;
        this.show_all_friends     = settings.show_all_friends;
        this.show_unread_messages = settings.show_unread_messages;
        this.show_typing_status   = settings.show_typing_status;
        this.send_typing_status   = settings.send_typing_status;
        this.contactlist_width    = settings.contactlist_width;
        this.enable_tray          = settings.enable_tray;
        this.enable_notify        = settings.enable_notify;
        this.enable_notify_sounds = settings.enable_notify_sounds;
        this.default_save_path    = settings.default_save_path;
      }
    } catch (Error e) {
      debug (@"Error loading settings: $(e.message)");
    }
  }

  public bool save_settings () {
    Json.Node root = Json.gobject_serialize (this);
    Json.Generator generator = new Json.Generator ();
    generator.set_root (root);
    generator.pretty = true;

    File settings_file = File.new_for_path (this.profile);

    try {
      DataOutputStream dos = new DataOutputStream (settings_file.replace (
        null, false,
        FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION
      ));
      generator.to_stream (dos);

      //debug (@"Saving settings to $(this.profile)");
      return true;
    } catch (Error e) {
      debug (@"Error saving settings: $(e.message)");
      return false;
    }
  }
}
