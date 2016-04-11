# Installing Ricin
## Needed dependencies
# Dependencies
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
| libconfig      |            | >=1.5.0   |

## Fetching the dependencies
### Ubuntu (debian based)
On ubuntu you'll need to compile ToxCore, Libsodium, and filter_audio by hand, since someone already wrote how to achieve this, please follow this guide before doing the commands beside → https://github.com/irungentoo/toxcore/blob/master/INSTALL.md#build-manually

```bash
$ apt-get install libglib2.0-0 libglib2.0-dev libjson-glib-1.0-0 libjson-glib-dev libsoup-gnome2.4-dev libnotify-dev
```
You'll also need libconfig that is available here: https://launchpad.net/ubuntu/wily/+package/libconfig-dev

_Note that Ubuntu may prompt you for running this command in root. Just add `sudo` before the command and run it._

### Arch (and similar distro)
```bash
$ pacman -S meson ninja vala gtk3 toxcore glib2 json-glib libsoup libnotify libconfig
```

### Fedora
On Fedora you'll need to compile ToxCore, Libsodium, and filter_audio by hand, since someone already wrote how to achieve this, please follow this guide before doing the commands beside → https://github.com/irungentoo/toxcore/blob/master/INSTALL.md#build-manually
```bash
$ dnf install valac glib2 gtk3 gtk3-devel json-glib libsoup libnotify libconfig libconfig-dev
```
## Install Ricin
### Linux
Please reffer to the [INSTALL.md] to install the dependencies on your Linux distribution.

#### ArchLinux
Thanks to [LastAvenger] Arch users can enjoy a package located here: [ricin-git]  
Installing the package from a shell is simple as doing this:
```bash
yaourt -S ricin-git
```

#### Other Linux distributions
For other systems that doesn't yet have a package you'll have a to compile & install Ricin from sources.  
First, install Ricin's <a href="#dependencies">dependencies</a> then run the following commands in a shell:
```bash
git clone --recursive https://github.com/RicinApp/Ricin.git && cd Ricin
make autogen
sudo make install
```

### Windows
Ricin isn't yet available on Windows, anyway this is planed.

### OSX
Ricin isn't yet available on OSX, anyway this is also planed!
