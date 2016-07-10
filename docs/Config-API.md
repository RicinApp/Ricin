# Ricin Config API
This document aims to cover every supported property in the `ricin.json` user-preferences file.  
Here are described every property you may use in the file, not defined here proprerties are likely
to not work/works badly.

For more informations about the config API, just take a look at the [Settings.vala](../src/Settings.vala) file.

## (String) last-profile
* **Usage**: The last profile used name.
* **Default**: `null`
* **Sample**:  
  Here `{name}` is the file name like `~/.config/tox/{name}.tox`.  
  ```json
  "last-profile": "{name}",
  ```

## (Boolean) network-udp
* **Usage**: A property to define if ToxCore should use UDP.
* **Default**: `true`
* **Sample**: 
  ```json
    "network-udp": true,
  ```
  
## (Boolean) network-ipv6
* **Usage**: A property to define if ToxCore should use IPv6.
* **Default**: `true`
* **Sample**: 
  ```json
    "network-ipv6": true,
  ```
  
## (Boolean) enable-proxy
* **Usage**: A property to define if ToxCore should use a **SOCKS5** proxy.
* **Default**: `false`
* **Sample**: 
  ```json
    "enable-proxy": true,
  ```
  
## (String) proxy-host
* **Usage**: If `enable-proxy` is enabled, this is the proxy address that ToxCore will connect via.
* **Default**: `127.0.0.1`
* **Sample**: 
  ```json
    "proxy-host": "127.0.0.1",
  ```

## (Integer) proxy-port
* **Usage**: If `enable-proxy` is enabled, this is the proxy port that ToxCore will connect via.
* **Default**: `9050` (Tor)
* **Sample**: 
  ```json
    "proxy-port": 9050,
  ```

## (Boolean) enable-custom-themes
* **Usage**: If enabled, allows Ricin to use custom themes.
* **Default**: `true`
* **Sample**: 
  ```json
    "enable-custom-themes": true,
  ```

## (String) selected-theme
* **Usage**: If `enable-custom-themes` is enabled, this is the theme that Ricin will use to render the window.
* **Default**: `dark`
* **Sample**: 
  ```json
    "selected-theme": "white",
  ```

## (String) selected-language
* **Usage**: This is the language that Ricin will use to render the window.
* **Default**: `en_US`
* **Sample**: 
  ```json
    "selected-language": "fr_FR",
  ```

## (Boolean) show-status-change
* **Usage**: If enabled Ricin will display friends status changes in their ChatView.
* **Default**: `true`
* **Sample**: 
  ```json
    "show-status-change": true,
  ```

## (Boolean) show-unread-messages
* **Usage**: If enabled and scrollbar isn't at it's maximum bottom, Ricin will show a little notice to inform the user that new messages are available in this chat.
* **Default**: `true`
* **Sample**: 
  ```json
    "show-unread-messages": true,
  ```

## (Boolean) show-typing-status
* **Usage**: If enabled Ricin will display friends typing status changes in their ChatView.
* **Default**: `true`
* **Sample**: 
  ```json
    "show-typing-status": true,
  ```

## (Boolean) send-typing-status
* **Usage**: If enabled Ricin will send `self_is_typing` notifications to the friend with who the user talks.
* **Default**: `true`
* **Sample**: 
  ```json
    "send-typing-status": false,
  ```

## (String) default-save-path
* **Usage**: The path for Ricin to store downloaded files to. May be overriden in the future with per-friend download folder.
* **Default**: OS `Downloads` folder.
* **Sample**: 
  ```json
    "default-save-path": "/home/user/Downloads/Tox/",
  ```
  
## (Boolean) compact-mode
* **Usage**: If enabled Ricin will display the friends list in a more compact way, allowing to see more contacts.
* **Default**: `false`
* **Sample**: 
  ```json
    "compact-mode": true,
  ```









