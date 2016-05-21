#!/bin/bash

########################################################################
# Package the binaries built on Travis-CI as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################

export ARCH=$(arch)

APP=Ricin
LOWERAPP=${APP,,}

GIT_REV=$(git rev-parse --short HEAD)
echo $GIT_REV

# /home/travis/build/RicinApp/Ricin/dist

cd /home/travis/build/RicinApp/Ricin/

wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

cd dist

find .

########################################################################
# Copy desktop and icon file to AppDir for AppRun to pick them up
########################################################################

get_apprun

find . -name *desktop -exec cp {} $LOWERAPP.desktop \;

find . -name $LOWERAPP.png -exec cp {} $LOWERAPP.png \; ### FIXME

########################################################################
# Copy in the dependencies that cannot be assumed to be available
# on all target systems
########################################################################

export LD_LIBRARY_PATH=/home/travis/build/RicinApp/Ricin/dist/lib/:LD_LIBRARY_PATH
copy_deps

# Move the libraries to usr/bin
move_lib
mv usr/lib/x86_64-linux-gnu/* usr/lib/

########################################################################
# Delete stuff that should not go into the AppImage
########################################################################

# Delete dangerous libraries; see
# https://github.com/probonopd/AppImages/blob/master/excludelist
delete_blacklisted

# We don't bundle the developer stuff
rm -rf usr/include || true
rm -rf usr/lib/cmake || true
rm -rf usr/lib/pkgconfig || true
find . -name '*.la' | xargs -i rm {}
strip usr/bin/* usr/lib/* || true

########################################################################
# desktopintegration asks the user on first run to install a menu item
########################################################################

get_desktopintegration $LOWERAPP

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

GLIBC_NEEDED=$(glibc_needed)
VERSION=git$GIT_REV-glibc$GLIBC_NEEDED

########################################################################
# Patch away absolute paths; it would be nice if they were relative
########################################################################

# TODO

########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd .. # Go out of AppImage

mkdir -p ../out/
generate_appimage

########################################################################
# Upload the AppDir
########################################################################

transfer ../out/*
