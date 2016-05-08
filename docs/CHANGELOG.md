## 0.0.9 (2016-05-08)
#### Bug Fixes
* **credits:**  add credits to the original identicon.js author ([296f1c45](https://github.com/RicinApp/Ricin/commit/296f1c45a89f2622b65f4ea28ff5c15703f555f0))
* **delete friend:**  now remove the friendlistrow + focus -1 ([f39082b4](https://github.com/RicinApp/Ricin/commit/f39082b496466c061c08ff9ebfad1bcb6c81821b))
* **file transfers:**  file save segfault. Fix #91 * Fixed the issue that was causing Ricin to   segfault when two files with the same name   were saved at the same location. This is simply   done by prepending a random id that's seeded   with the current DateTime. ([cb3f82ff](https://github.com/RicinApp/Ricin/commit/cb3f82ff345af8bf2c088ff31ef5f73234c043b2))
* **i18n + identicons:**  remove identicons background ([3d0bcd6a](https://github.com/RicinApp/Ricin/commit/3d0bcd6a2f5e3dd59d847035f1e31c372534e1fb))
* **identicons:**  don't use nospam to render identicon ([90313082](https://github.com/RicinApp/Ricin/commit/903130821af9a0f6d850c7a8d39256b099acf75b))
* **linux packager:**  add `install.sh` in the final archive ([4d106483](https://github.com/RicinApp/Ricin/commit/4d106483305db05c75ef5a45f14c85716a96b750))
* **markdown:**  astyle broked regexes ([9c5bac1a](https://github.com/RicinApp/Ricin/commit/9c5bac1a2a2b7c192ced19dd2acebfe12f316ab8))

#### Features
* **add friend:**  allow user to add a friend via public key (#117) ([786de973](https://github.com/RicinApp/Ricin/commit/786de973cb5c5ac04d5c26809c1cd9700f1e3f2a))
* **entry command:**  add /clear to empty the ChatView ([c04b7b3c](https://github.com/RicinApp/Ricin/commit/c04b7b3c4d61e4d1e5eff965de2072ae2e001063))
* **keyboard shortcut:**  ctrl+up and ctrl+down to change contacts quickly ([06deaba3](https://github.com/RicinApp/Ricin/commit/06deaba390a84b0acc88ce2c2026cc942caa0b20))

## 0.0.8 (2016-04-30)
#### Bug Fixes
* **port range:**  allow for bigger port range, hope it fix #68 ([a50798bb](https://github.com/RicinApp/Ricin/commit/a50798bbeaa8443b1b2c98be0645d3d3e904fc59))

#### Features
* **ToxIdenticons:**  users without avatars now have identicon (#115) ([617f8987](https://github.com/RicinApp/Ricin/commit/617f898738b9ec4f398311b003e90c96a52b98f1))
* **compact mode:**  add a way to display more friends in the window (#113) ([85b39bff](https://github.com/RicinApp/Ricin/commit/85b39bfffe6c1476e31396af9befd10747baa9ab))

## 0.0.7 (2016-04-28)
#### Bug Fixes
* **Markdown:**
  *  links are now formated correctly ([39c525b1](https://github.com/RicinApp/Ricin/commit/39c525b1391f266b70f0989e4aae0d3b35cdd77f))
  *  doesn't parse markdown inside code blocks ([d0ada8f7](https://github.com/RicinApp/Ricin/commit/d0ada8f79050674cc2779add3a7e723aefd90f29))
* **libtoxencryptsave:**  vapi fix ([87b49895](https://github.com/RicinApp/Ricin/commit/87b49895f8e5278df7a35155dcff80c76092c8be))
* **login:**  button wasn't enabled if issue occured ([391bf245](https://github.com/RicinApp/Ricin/commit/391bf24507e663df0be494e93f6519a473c7c7ec))
* **notification:**  only show notification if user isn't busy ([4635aba8](https://github.com/RicinApp/Ricin/commit/4635aba844b9773663fe64b6cf6b5791f40d1cc3))
* **port range:**  allow for bigger port range, hope it fix #68 ([a50798bb](https://github.com/RicinApp/Ricin/commit/a50798bbeaa8443b1b2c98be0645d3d3e904fc59))
* **tooltip:**  change tooltip when text changes ([b3596e71](https://github.com/RicinApp/Ricin/commit/b3596e7162b2534f1c3904262809d944684a341a))
* **toxencryptsave:**  typo ([7b6a38fe](https://github.com/RicinApp/Ricin/commit/7b6a38fe5f54e3e4337b2ad8f4f7cdd0ca2f133e))

## 0.0.4.1 (2016-04-11)
#### Bug Fixes
* **Ricin.vala:**
  *  create Tox directories if they don't exists ([0c67ceac](https://github.com/RicinApp/Ricin/commit/0c67ceace3faf55bbc52d28401a84ab4cacc313a))
  *  create directories if not existing ([97524313](https://github.com/RicinApp/Ricin/commit/97524313cd8773281ca5ba5d9e862a533b83a5f8))
  *  fix a weird issue with travis ([e8ebe028](https://github.com/RicinApp/Ricin/commit/e8ebe02825b1c103fb9e3439adf62f5df757b6d0))
* **Utils.render_littlemd:**
  *  typo, close #96 Forgot to declare the `message` variable... ([b2d6f629](https://github.com/RicinApp/Ricin/commit/b2d6f629931375f3559952c5879f1d93c5d897a4))
  *  return plain text if error The `Utils.render_littlemd` method now return plaintext message if the markdown regexes failed, this should avoid `label` messages as described in #95. Close #95 ([bf3a2125](https://github.com/RicinApp/Ricin/commit/bf3a2125ee9d25df722b8510271c45cd5818040c))
* **Utils.vala:**
  *  typo fix ([d5a68819](https://github.com/RicinApp/Ricin/commit/d5a68819119e347b5a8fa5b14c5151a097380819))
  *  remove `Markdown` namespace This commit removes the `using Markdown;` line since we doesn't use `libmarkdown`. This was added by a test that I pushed by error... ([cb89edd7](https://github.com/RicinApp/Ricin/commit/cb89edd7f6e2dc05cbdee5057dd33b42b630d3e6))
* **chatview:**  textbox loosing focus, fix & close #93. The issue was that when a friend was typing being not the current conversation the current entry was loosing the focus, this commit fix the issue and closes #93. ([628494f2](https://github.com/RicinApp/Ricin/commit/628494f214b41fe5d3f2687c4bb2226da03aea94))
* **profile:**  ellipsize name + status message ([06df83fd](https://github.com/RicinApp/Ricin/commit/06df83fd79264d7bc3c424e26fb39f27b01b8ba6))
* **rpm:**  removed rpm ([0b383b5e](https://github.com/RicinApp/Ricin/commit/0b383b5e9b50fced94d363bb7f407f47dfb55bfc))
* **security:**  
  * Removed string literals in message_formats
  * Removed a potential security issue. ([8a0c2bbc](https://github.com/RicinApp/Ricin/commit/8a0c2bbca172955dfc30168e26a2dbd4c1220291))
* **settings:**  try/catch get_string() ([165945ac](https://github.com/RicinApp/Ricin/commit/165945ac6f8a55d4286238ab43e564773b7a9d0a))
* **tooltips:**
  *  use markup for tooltips ([80d24c4b](https://github.com/RicinApp/Ricin/commit/80d24c4bb068e9bd1bb17c90c168a0206484a97d))
  *  add Tooltip for ellipsized strings
  *  Add a tooltip with complete text for own status message
  *  Add a tooltip with complete text for friends status message ([e919de00](https://github.com/RicinApp/Ricin/commit/e919de000da452ad118e0021c29e103ff11e301b))
* **travis:**  change GTK+3.18 PPA, fix #44 ([160d5f18](https://github.com/RicinApp/Ricin/commit/160d5f18dc09a0c03f1e2a66b83488427810cb03))
