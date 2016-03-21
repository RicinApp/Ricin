#!/bin/sh

curdir=`pwd`
rm -rf ../buildtmp
mkdir -p ../buildtmp
LDFLAGS=-static-libstdc++ meson ../buildtmp --buildtype=release --prefix=/tmp/ricin --libdir=lib --strip
type ninja-build 2>/dev/null && ninja-build -C ../buildtmp install || ninja -C ../buildtmp install
rm -rf ../buildtmp
cd /tmp/
tar czf ricin.tar.gz ricin
mv ricin.tar.gz "$curdir"
rm -rf ricin
