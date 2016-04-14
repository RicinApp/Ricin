#!/bin/sh

echo "Installing Ricin's dependencies from Homebrew"
brew install vala ninja gtk+3 glib json-glib libsoup libnotify brew-pip

echo "Installing The Meson Build System from brew-pip"
brew pip meson

echo "Auto generating needed files for compilation"
cd ..
make autogen

echo "Starting build_osx_package.sh"
chmod +x ./tools/build_osx_package.sh
./tools/build_osx_package.sh
