<a id="0.0.4.1"></a>
## 0.0.4.1 (2016-04-11)

#### Bug Fixes

* **Ricin.vala:**
  *  create Tox directories if they don't exists ([0c67ceac](0c67ceac))
  *  create directories if not existing ([97524313](97524313))
  *  fix a weird issue with travis ([e8ebe028](e8ebe028))
* **Utils.render_littlemd:**
  *  typo, close #96 Forgot to declare the `message` variable... ([b2d6f629](b2d6f629))
  *  return plain text if error The `Utils.render_littlemd` method now return plaintext message if the markdown regexes failed, this should avoid `label` messages as described in #95. Close #95 ([bf3a2125](bf3a2125))
* **Utils.vala:**
  *  typo fix ([d5a68819](d5a68819))
  *  remove `Markdown` namespace This commit removes the `using Markdown;` line since we doesn't use `libmarkdown`. This was added by a test that I pushed by error... ([cb89edd7](cb89edd7))
* **chatview:**  textbox loosing focus, fix & close #93 The issue was that when a friend was typing being not the current conversation the current entry was loosing the focus, this commit fix the issue and closes #93. ([628494f2](628494f2))
* **profile:**  ellipsize name + status message ([06df83fd](06df83fd))
* **rpm:**  removed rpm ([0b383b5e](0b383b5e))
* **security:**  Removed string literals in message_formats Removed a potential security issue. ([8a0c2bbc](8a0c2bbc))
* **settings:**  try/catch get_string() ([165945ac](165945ac))
* **tooltips:**
  *  use markup for tooltips ([80d24c4b](80d24c4b))
  *  add Tooltip for ellipsized strings * Add a tooltip with complete text for own status message * Add a tooltip with complete text for friends status message ([e919de00](e919de00))
* **travis:**  change GTK+3.18 PPA, fix #44 ([160d5f18](160d5f18))
