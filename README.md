# **Ricin** - A dead-simple but powerful Tox client
### [Download] - [Install] - [Compile] - [Contribute] - [Translate] - [Donate] - [Discover Vala]

[![Ricin license](https://img.shields.io/badge/license-GPLv3-blue.svg?style=flat)](https://raw.githubusercontent.com/RicinApp/Ricin/master/LICENSE)
[![Ricin release](https://img.shields.io/github/release/RicinApp/Ricin.svg?style=flat)](https://github.com/RicinApp/Ricin/releases/latest)
[![Ricin open issues](https://img.shields.io/github/issues/RicinApp/Ricin.svg?style=flat)](https://github.com/RicinApp/Ricin/issues)
[![Codecov master](https://img.shields.io/codecov/c/github/RicinApp/Ricin/master.svg?style=flat)](https://codecov.io/github/RicinApp/Ricin)
[![TravisCI](https://img.shields.io/travis/RicinApp/Ricin/master.svg?style=flat)](https://travis-ci.org/RicinApp/Ricin)

# Introduction
**Ricin** aims to be a _secure_, _lightweight_, _hackable_ and _fully-customizable_ chat client using the awesome and open-source **ToxCore** library. We know that there are several Tox clients but this project was initially made because the other clients are still missing many features that users have been waiting for over many months. Ricin is a simple but powerful cross-platform client written in Vala and using Gtk+ 3.0.

_Screenshot might be outdated but it should give you a general idea of what Ricin is_
![Early version](http://i.imgur.com/f7np85T.png)

# Download
## Linux
You can download Ricin as an AppImage. An AppImage is a single file that contains Ricin + the required libraries.  
The main goal of this is having Ricin working on every Linux distribution without the hassle of installing any dependency.  

Downloading and running Ricin is simple as doing the following:
```shell
# Assuming that the current version is 0.1.1
wget https://cdn.ricin.im/ricin-0.1.1.app
chmod a+x ricin-0.1.1.app
./ricin-0.1.1.app
```

## Windows
Ricin for Windows can be downloaded at the following URL.  
*Please note that this is the first release of Ricin for Windows and that it may
contains bugs, please report any of them (even the insignifiant ones) via the
issue tracker.*

* [Ricin for Windows (64 bits)](https://cdn.ricin.im/windows/ricin-0.1.1-win32_x86-64.zip)

# Install
Installation instructions are available inside our [INSTALL.md] file. :)

# Compile
Please refer to the [INSTALL.md] to install the dependencies on your Linux distribution.

```bash
git clone https://github.com/RicinApp/Ricin.git && cd Ricin
alias waf=$PWD/waf
waf configure
waf build
```

# Donate
There are plenty of way you can donate to Ricin. All the money received will be used to work at full-time on Ricin. You can even tell us what you want to be worked on by backing an issue!
- [Paying us a Bounty]
- **Bitcoin:** btc.ricin.im (OpenAlias) or [3L7B6XAQM27uxfRK8wUQ4fsfja832EKweM](https://blockchain.info/address/3L7B6XAQM27uxfRK8wUQ4fsfja832EKweM)
- **Litecoin:** ltc.ricin.im (OpenAlias) or [LUDFUqvZkjXCvaroNiap5vXHzMGeTB8F8x](https://bchain.info/LTC/addr/LUDFUqvZkjXCvaroNiap5vXHzMGeTB8F8x)
- **Other ways:** Ways that are not secure (paypal, etc) are not allowed, sorry. :/

# Translate
Ricin uses Transifex in order to maintain Localization and enable users to help us translating it in their native language.  
Here's a graphic about the translations' state:

![Translations state for Ricin](https://www.transifex.com/projects/p/ricin/resource/ricinpot/chart/image_png)

## How to translate
In order to make a translation, please create an account on Transifex, then [go to this page] and select the language you want to translate it. Transifex will redirect you to a page where you'll be able to translate Ricin's strings.

**Please respect the following rules while translating:**
- Always use the same markup as the original string.
- Don't remove trailing spaces if any, they are needed for Ricin to display text correctly.
- Please try to translate using similar words, don't use funny words.
- Write the sentences in an imperative way.
- Translations will be reviewed string by string and parts of it could be rejected it the above rules are not respected.

# Discover Vala
Before clicking on any link below, you must know what Vala is and why it is so powerful and easy to use: [What is Vala?]

- [Official Vala website](https://live.gnome.org/Vala)
- [Official Vala documentation](http://www.valadoc.org)
- [Download Vala compiler and tools](https://wiki.gnome.org/Projects/Vala/Tools)
- [The Vala Tutorial](https://wiki.gnome.org/Projects/Vala/Tutorial): (English) (Spanish) (Russian) (Hebrew)
- [Vala for C# Programmers](https://wiki.gnome.org/Projects/Vala/ValaForCSharpProgrammers)
- [Vala for Java Programmers](https://wiki.gnome.org/Projects/Vala/ValaForJavaProgrammers): (English) (Russian)
- [Vala memory management explained](https://wiki.gnome.org/Projects/Vala/ReferenceHandling)
- [Writing VAPI files](https://wiki.gnome.org/Projects/Vala/LegacyBindings): A document that explains how to write VAPI binding files for a C library.

[Ricin]: https://ricin.im
[Download]: #download
[Install]: #install
[Compile]: #compile
[Contribute]: docs/CONTRIBUTING.md
[Translate]: #translate
[Donate]: #donate
[Discover Vala]: #discover-vala

[INSTALL.md]: docs/INSTALL.md
[Paying us a Bounty]: https://www.bountysource.com/teams/RicinApp
[go to this page]: https://www.transifex.com/ricinapp/ricin/
[What is Vala?]: https://wiki.gnome.org/Projects/Vala/About
