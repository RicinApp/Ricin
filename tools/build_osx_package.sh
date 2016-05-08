#!/bin/sh
# OSX .dmg build maker

curdir=`pwd`
tmpdir="/tmp/ricin.app"
bindir="Contents/MacOS"

cd "$curdir"
./waf configure --exec-prefix="$tmpdir" --prefix="$tmpdir" --libdir=lib --bindir="$bindir"
./waf build --exec-prefix="$tmpdir" --prefix="$tmpdir" --libdir=lib --bindir="$bindir"

mkdir -p "$tmpdir"
./waf install --exec-prefix="$tmpdir" --prefix="$tmpdir" --libdir=lib --bindir="$bindir"

cd "$tmpdir"
mkdir -p mnttmp
gunzip < "$curdir/tools/template.dmg.gz" > working.dmg
hdiutil attache working.dmg -noautoopen -quiet -mountpoint mnttmp

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
