<table align="center" width="100%" style="margin: 0 auto;">
  <tr>
    <td align="center">
      <strong><a href="https://ricin.im">Ricin</a></strong>
    </td>
    <td align="center">
      <img src="https://img.shields.io/badge/version-0.0.3%20beta-brightgreen.svg?style=flat">
      <a href="https://codetree.com/projects/18p9/issues">
        <img src="https://codetree.com/images/managed-with-codetree.svg">
      </a>
      <a href="https://www.bountysource.com/teams/RicinApp">
        <img src="https://img.shields.io/bountysource/team/RicinApp/activity.svg?style=flat" alt="Support development">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" width="100%" colspan="2">
      <big><b>Wants to be involved? Their is several way to help us! ^-^</b></big><br>
      <a href="#translating">Translating</a> -
      <a href="#dependencies">Dependencies</a> -
      <a href="#compiling">Compiling</a> -
      <a href="#contribute">Contribute</a> -
      <a href="#support-ricin-developement">Support us</a> -
      <a href="#vala-resources-to-get-started">Get started with Vala</a>
    </td>
  </tr>
</table>

# Introduction
**Ricin** aims to be a _secure_, _lightweight_, _hackable_ and _fully-customizable_ chat client using the awesome and open-source **ToxCore** library. We know that there are several Tox clients but this project was initially made because the other clients are still missing many features that users have been waiting for over many months. Ricin is a simple but powerful cross-platform client written in Vala and using Gtk+ 3.0.

_Screenshot might be outdated but it should give you a general idea of what is Ricin_
![Early version](https://ricin.im/static/images/ricin_01.png)

# Dependencies
| Package name        | Version   |
|---------------------|-----------|
| [meson] \(building) | >=0.28.0  |
| [ninja] \(building) | >=1.5.1   |
| valac \(building)   | >=0.28.1  |
| gtk+3               | >=3.16    |
| [libtoxcore]        | >=0.0.0   |
| glib2               | >=2.38    |
| json-glib           | >=1.0     |
| libsoup             | >=2.4     |
| libnotify           | >=0.0.0   |
| libconfig           | >=0.0.0   |

# Installing
We currently have an ArchLinux package made by @LastAvenger available at the following url: [ricin-git](https://aur.archlinux.org/packages/ricin-git/)
You can also use the following command:
```
yaourt -S ricin-git
```

# Compiling
Please refer to the [Install.md](INSTALL.md) to install the dependencies on your Linux distribution.

```bash
git clone --recursive https://github.com/RicinApp/Ricin.git
cd Ricin
mkdir build
meson . build
make debug
```

# Contribute
You can contribute to improving Ricin by [proposing Pull-requests](https://github.com/RicinApp/Ricin/pulls), reporting bugs or suggestions using the GitHub [issues tracker](https://github.com/RicinApp/Ricin/issues), [submiting a Bounty](https://www.bountysource.com/teams/RicinApp) or even [Translating Ricin in your native language](#translating)

> _Section to complete..._

# Support Ricin developement
You can support the Ricin client developement by
- [Paying us a Bounty](https://www.bountysource.com/teams/RicinApp)
- **Bitcoin:** btc.ricin.im (OpenAlias) or [3L7B6XAQM27uxfRK8wUQ4fsfja832EKweM](https://blockchain.info/address/3L7B6XAQM27uxfRK8wUQ4fsfja832EKweM)
- **Litecoin:** ltc.ricin.im (OpenAlias) or [LUDFUqvZkjXCvaroNiap5vXHzMGeTB8F8x](http://explorer.litecoin.net/address/LUDFUqvZkjXCvaroNiap5vXHzMGeTB8F8x)
- Backing an issue via Bountsource to make people able to work on it full-time! :)

# Translating
Ricin uses Transifex in order to maintain Localization and enable users to help us translating it in their native language. Here's a graphic about the translations state:

![Translations state for Ricin](https://www.transifex.com/projects/p/ricin/resource/ricinpot/chart/image_png)

## How to translate
In order to make a translation, please create an account on Transifex, then [go to this page](https://www.transifex.com/ricinapp/ricin/ricinpot/) and select the language you want to translate it. Transifex will redirect you to a page where you'll have to translate Ricin's strings.

**Please respect the following rules while translating:**
- Always use the same markup as the original string.
- Doesn't remove trailing spaces, they are needed for Ricin to display text correctly.
- Please try to translate using similar words, doesn't uses funny words.
- Write the sentences in a imperative way.

# Vala resources to get started
Before clicking on any link beside, you must know what is Vala and why it is so powerful and easy to use: [What is Vala?](https://wiki.gnome.org/Projects/Vala/About)

- [Official Vala website](https://live.gnome.org/Vala)
- [Official Vala documentation](http://www.valadoc.org)
- [Download Vala compiler and tools](https://wiki.gnome.org/Projects/Vala/Tools)
- [The Vala Tutorial](https://wiki.gnome.org/Projects/Vala/Tutorial): (English) (Spanish) (Russian) (Hebrew)
- [Vala for C# Programmers](https://wiki.gnome.org/Projects/Vala/ValaForCSharpProgrammers)
- [Vala for Java Programmers](https://wiki.gnome.org/Projects/Vala/ValaForJavaProgrammers): (English) (Russian)
- [Vala memory management explained](https://wiki.gnome.org/Projects/Vala/ReferenceHandling)
- [Writing VAPI files](https://wiki.gnome.org/Projects/Vala/LegacyBindings): A document that explains how to write VAPI binding files for a C library.

# Mockups

See
- https://github.com/gnome-design-team/gnome-mockups/tree/master/chat
- https://wiki.gnome.org/Design/Apps/Chat
- [misc/mockup2.png](misc/mockup2.png)

[libtoxcore]: https://github.com/irungentoo/toxcore/blob/master/INSTALL.md
[meson]: http://mesonbuild.com/
[ninja]: http://martine.github.io/ninja/
