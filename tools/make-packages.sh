#!/bin/bash

###
# Ricin packages maker
# Use fpm to generate rpm/arch/deb/tar.gz packages.
# @author SkyzohKey
# @license MIT
###

fpm --verbose \
  --replaces Ricin \
  --depends vala \
  --license "GPLv3" \
  --url "https://ricin.im" \
  --description "Dead simple, privacy oriented, instant messaging app! " \
  -a $(uname -m) \
  -C ../build \
  -s dir -t rpm -f \
  -p Ricin-VERSION-$RICIN_ITER.ARCH.rpm \
  -n Ricin \
  -v $RICIN_VERSION \
  --iteration $RICIN_ITER \
  ./Ricin=/usr/bin/Ricin \
  ./res/ricin.desktop=/usr/share/applications/ricin.desktop \
  ../res/images/icons/ricin.svg=/usr/share/pixmaps/ricin.svg \
  ../res/ricin.appdata.xml=/usr/share/appdata/ricin.appdata.xml
