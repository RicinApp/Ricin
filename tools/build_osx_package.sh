#!/bin/sh

rm -rf ../buildtmp
mkdir -p ../buildtmp
meson ../buildtmp --buildtype=release  --prefix=/tmp/ricin.app --bindir=Contents/MacOS
type ninja-build 2>/dev/null && ninja-build -C ../buildtmp install || ninja -C ../buildtmp install
rm -rf ../buildtmp
mkdir -p mnttmp
rm -f working.dmg
gunzip < template.dmg.gz > working.dmg
hdiutil attach working.dmg -noautoopen -quiet -mountpoint mnttmp
# NOTE: output of hdiutil changes every now and then.
# Verify that this is still working.
DEV=`hdiutil info|tail -1|awk '{print $1}'`
rm -rf mnttmp/ricin.app
mv /tmp/ricin.app mnttmp
hdiutil detach ${DEV}
rm -rf mnttmp
rm -f ricin.dmg
hdiutil convert working.dmg -quiet -format UDZO -imagekey zlib-level=9 -o ricin.dmg
rm -f working.dmg
