# Ricin installation guide
## Needed dependencies
| Package name   | Notes      | Version   |
|:---------------|:----------:|----------:|
| [meson]        |  building  | >=0.30.0  |
| [ninja]        |  building  | >=1.5.1   |
| valac          |  building  | >=0.28.1  |
| gtk+3          |            | >=3.16    |
| [libtoxcore]   |            | >=0.0.0   |
| glib2          |            | >=2.38    |
| json-glib      |            | >=1.0     |
| libsoup        |            | >=2.4     |
| libnotify      |            | >=0.7.6   |

## Fetching the dependencies
### Ubuntu & debian based
On Ubuntu you need to compile ToxCore, Libsodium, and filter_audio by hand. Someone already wrote on how to achieve this, simply follow the guide to [Install ToxCore].

After ToxCore is installed, run the following line to fetch & install the dependencies needed by Ricin to compile/run.

```bash
# Required to build Ricin:
$ apt-get install ninja meson valac

# Required by Ricin at runtime:
$ apt-get install gtk+3 libglib2.0-0 libglib2.0-dev \
  libjson-glib-1.0-0 libjson-glib-dev libnotify-dev \
  libsoup-gnome2.4-dev
```

>**Note**: You may have to `sudo` both lines in order to have
them running properly.

### Arch (and similar distro)
To install all the Ricin's dependencies, simply write the
following in a shell.

```bash
$ pacman -S meson ninja vala gtk3 toxcore \
  glib2 json-glib libsoup libnotify
```

### Fedora
On Fedora you need to compile ToxCore, Libsodium, and filter_audio by hand. Someone already wrote on how to achieve this, simply follow the guide to [Install ToxCore].

```bash
$ dnf install valac glib2 gtk3 gtk3-devel \
  json-glib libsoup libnotify
```

## Installing Ricin
### Linux
#### ArchLinux
Thanks to [LastAvenger], ArchLinux users can install Ricin with a package that can be found here: [ricin-git]. You simply have to write the following line in a shell:

```bash
$ yaourt -S ricin-git
```

#### Other Linux distributions
For other systems that doesn't yet have a package you have a to compile and install Ricin from sources. Compiling Ricin is super simple as we use **The Meson Build System** that runs pretty much everywhere.  

Run the following commands in a shell:
```bash
git clone --recursive https://github.com/RicinApp/Ricin.git
cd Ricin
make autogen
sudo make install
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
[Install ToxCore]: https://github.com/irungentoo/toxcore/blob/master/INSTALL.md#build-manually
