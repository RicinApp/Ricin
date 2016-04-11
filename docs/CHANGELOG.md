<a name=""></a>
##  (2016-04-11)


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
* **chatview:**  textbox loosing focus, fix & close #93 The issue was that when a friend was typing being not the current conversation the current entry was loosing the focus, this commit fix the issue and closes #93. ([628494f2](https://github.com/RicinApp/Ricin/commit/628494f214b41fe5d3f2687c4bb2226da03aea94))
* **profile:**  ellipsize name + status message ([06df83fd](https://github.com/RicinApp/Ricin/commit/06df83fd79264d7bc3c424e26fb39f27b01b8ba6))
* **rpm:**  removed rpm ([0b383b5e](https://github.com/RicinApp/Ricin/commit/0b383b5e9b50fced94d363bb7f407f47dfb55bfc))
* **security:**  Removed string literals in message_formats Removed a potential security issue. ([8a0c2bbc](https://github.com/RicinApp/Ricin/commit/8a0c2bbca172955dfc30168e26a2dbd4c1220291))
* **settings:**  try/catch get_string() ([165945ac](https://github.com/RicinApp/Ricin/commit/165945ac6f8a55d4286238ab43e564773b7a9d0a))
* **tooltips:**
  *  use markup for tooltips ([80d24c4b](https://github.com/RicinApp/Ricin/commit/80d24c4bb068e9bd1bb17c90c168a0206484a97d))
  *  add Tooltip for ellipsized strings * Add a tooltip with complete text for own status message * Add a tooltip with complete text for friends status message ([e919de00](https://github.com/RicinApp/Ricin/commit/e919de000da452ad118e0021c29e103ff11e301b))
* **travis:**  change GTK+3.18 PPA, fix #44 ([160d5f18](https://github.com/RicinApp/Ricin/commit/160d5f18dc09a0c03f1e2a66b83488427810cb03))
