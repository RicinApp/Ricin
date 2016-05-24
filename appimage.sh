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

sudo chown -R $USER /home/travis/build/

cd /home/travis/build/RicinApp/

wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

mv Ricin $APP.AppDir
cd $APP.AppDir
mv dist/ usr/

find .

########################################################################
# Copy desktop and icon file to AppDir for AppRun to pick them up
########################################################################

get_apprun

find . -name *desktop -exec cp {} $LOWERAPP.desktop \;
sed -i -e 's|Ricin|ricin|g' $LOWERAPP.desktop
sed -i -e 's|.svg||g' $LOWERAPP.desktop

wget https://raw.githubusercontent.com/RicinApp/ricin.im/master/static/images/apple-touch-icon.png -O $LOWERAPP.png ### FIXME

########################################################################
# Copy in the dependencies that cannot be assumed to be available
# on all target systems
########################################################################

# Workaround for:
# undefined symbol: g_type_check_instance_is_fundamentally_a
# Function g_type_check_instance_is_fundamentally_a was introduced in glib2-2.41.1
# Bundle libglib-2.0.so.0 - TODO: find a better solution, e.g., downgrade libglib-2.0 at compile time

export LD_LIBRARY_PATH=/home/travis/build/RicinApp/Ricin.AppImage/usr/lib/:LD_LIBRARY_PATH
copy_deps

# Move the libraries to usr/bin
move_lib
mv usr/lib/x86_64-linux-gnu/* usr/local/lib/* usr/lib/
rm -r usr/lib/x86_64-linux-gnu/ usr/local/lib/

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

rm -rf build docs filter_audio gcovr-* libsodium po res src tools toxcore vapis *.tar.gz codecov.yml ISSUE_TEMPLATE.md Makefile waf wscript 

########################################################################
# desktopintegration asks the user on first run to install a menu item
########################################################################

( cd usr/bin ; mv Ricin ricin )
get_desktopintegration $LOWERAPP

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

GLIBC_NEEDED=$(glibc_needed)
VERSION=git$GIT_REV-glibc$GLIBC_NEEDED

########################################################################
# Patch away absolute paths; it would be nice if they were relative
########################################################################

patch_usr

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
