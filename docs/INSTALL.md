# Ricin installation guide

## Table of Contents
* [Dependencies installation](#dependencies)
  * [Debian/Ubuntu](#debianubuntu)
  * [Arch Linux](#arch-linux)
  * [Fedora](#fedora)
* [Installing](#installing-ricin)
  * [GNU/Linux](#linux)
    * [Arch Linux](#arch-linux-1)
    * [Gentoo Linux](#gentoo-linux)
    * [Milis Linux](#milis-linux-milis-isletim-sistemi)
    * [Other linux distributions](#others-linux)
  * [Windows](#windows)

## Dependencies
| Package name           | Notes      | Version   |
|:-----------------------|:----------:|----------:|
| python2 **or** python3 |  building  |           |
| valac                  |  building  | >=0.28.1  |
| intltool               |  building  | >=0.35.5  |
| gtk+3                  |            | >=3.16    |
| [libtoxcore]           |            | >=0.0.0   |
| glib2                  |            | >=2.38    |
| json-glib              |            | >=1.0     |
| libsoup                |            | >=2.4     |
| libnotify              |            | >=0.7.6   |

### Debian/Ubuntu
On Ubuntu you need to compile ToxCore, Libsodium, and filter_audio from source.
There is already sufficient documentation on this process, simply follow the guide to [Install ToxCore].

After ToxCore is installed, run the following commands to fetch & install the dependencies needed by Ricin to compile/run.

```bash
# Required to build Ricin:
$ apt-get install python3 valac

# Required by Ricin at runtime:
$ apt-get install gtk+3 libglib2.0-0 libglib2.0-dev \
  libjson-glib-1.0-0 libjson-glib-dev libnotify-dev \
  libsoup-gnome2.4-dev
```

>**Note**: You may have to `sudo` both lines in order to have
them running properly.

### Arch Linux
To install all the Ricin's dependencies, simply write the
following in a shell.

```bash
$ pacman -S python3 vala gtk3 toxcore \
  glib2 json-glib libsoup libnotify
```

### Fedora
On Fedora you need to compile ToxCore, Libsodium, and filter_audio from souce.
There is already sufficient documentation on this process, simply follow the guide to [Install ToxCore].

```bash
$ dnf install python3 valac glib2 gtk3 gtk3-devel \
  json-glib libsoup libnotify
```

## Installing Ricin
### GNU/Linux
#### Arch Linux
Thanks to [LastAvenger], Arch Linux users can install Ricin via AUR: [ricin-git] / [ricin](https://aur.archlinux.org/packages/ricin).  
You simply have to write the following line in a shell:

```bash
# Fetch the source from git, build and install.
$ yaourt -S ricin-git

# Use the latest release (stable), build and install.
$ yatourt -S ricin
```

#### Gentoo Linux
Thanks to [gitgud-software](https://github.com/gitgud-software), Gentoo Linux and Funtoo Linux users can install Ricin using [layman](https://wiki.gentoo.org/wiki/Layman).

```bash
$ layman -o https://gitgud.io/snippets/90/raw -f -a ricin-overlay
$ layman -s ricin-overlay
$ emerge net-im/ricin
```
Gentoo and Funtoo users can also configure the ricin-overlay to be used as a portage repository by copying [ricin-overlay.conf](https://gitgud.io/gitgud-software/ricin-overlay/raw/master/ricin-overlay.conf) into ```/etc/portage/repos.conf/```, then syncing the portage tree.

```bash
$ emerge --sync
$ emerge net-im/ricin
```


#### Milis Linux (Milis Isletim Sistemi)
Thanks to [milisarge], [Milis Linux] users can install Ricin via MPS.  
You simply have to write the following line in a shell:

```bash
$ mps -kur ricin
```

#### Other GNU/Linux
For other systems that do not have a Ricin package, you have to compile and
install Ricin from source. Compiling Ricin is super simple as we use
**The Waf Build System** that runs pretty much everywhere.  

**Before** running the following commands, please ensure that you have installed
all the Ricin's dependencies.

Run the following commands in a shell:
```bash
git clone https://github.com/RicinApp/Ricin.git && cd Ricin
./waf configure --prefix=/usr/local
./waf build
sudo ./waf install
```

### Windows
Ricin for Windows can be downloaded at the following URL.  
*Please note that this is the first release of Ricin for Windows and that it may
contains bugs, please report any of them (even the insignifiant ones) via the
issue tracker.*

* [Ricin for Windows (64 bits)](https://cdn.ricin.im/windows/ricin-0.1.1-win32_x86-64.zip)

### OSX
Ricin isn't available yet on OSX, anyway this is also planed!

[libtoxcore]: https://github.com/irungentoo/toxcore/blob/master/INSTALL.md
[meson]: http://mesonbuild.com/
[ninja]: http://martine.github.io/ninja/
[LastAvenger]: https://github.com/LastAvenger
[ricin-git]: https://aur.archlinux.org/packages/ricin-git
[milisarge]: https://github.com/milisarge
[Milis Linux]: http://milis.gungre.ch
[Install ToxCore]: https://github.com/irungentoo/toxcore/blob/master/INSTALL.md#build-manually
