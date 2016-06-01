# Ricin installation guide

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
On Ubuntu you need to compile ToxCore, Libsodium, and filter_audio by hand.
Someone already wrote on how to achieve this, simply follow the guide
to [Install ToxCore].

After ToxCore is installed, run the following line to fetch & install
the dependencies needed by Ricin to compile/run.

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

### ArchLinux
To install all the Ricin's dependencies, simply write the
following in a shell.

```bash
$ pacman -S python3 vala gtk3 toxcore \
  glib2 json-glib libsoup libnotify
```

### Fedora
On Fedora you need to compile ToxCore, Libsodium, and filter_audio by hand.
Someone already wrote on how to achieve this, simply follow the guide
to [Install ToxCore].

```bash
$ dnf install python3 valac glib2 gtk3 gtk3-devel \
  json-glib libsoup libnotify
```

## Installing Ricin
### Linux
#### ArchLinux
Thanks to [LastAvenger], ArchLinux users can install Ricin via AUR: [ricin-git] / [ricin](https://aur.archlinux.org/packages/ricin).  
You simply have to write the following line in a shell:

```bash
# Fetch the source from git, build and install.
$ yaourt -S ricin-git

# Use the latest release (stable), build and install.
$ yatourt -S ricin
```

#### Milis Linux (Milis Isletim Sistemi)
Thanks to [milisarge], [Milis Linux] users can install Ricin via MPS.  
You simply have to write the following line in a shell:

```bash
$ mps -kur ricin
```

#### Others Linux
For other systems that doesn't yet have a package you have a to compile and
install Ricin from sources. Compiling Ricin is super simple as we use
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
Ricin isn't available yet on Windows, anyway this is planed.

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
