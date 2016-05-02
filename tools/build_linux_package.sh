#!/bin/sh

curdir=`pwd`
rm -rf ../buildtmp
mkdir -p ../buildtmp
meson.py ../buildtmp --buildtype=release --prefix=/tmp/ricin --libdir=lib --strip
type ninja-build 2>/dev/null && ninja-build -C ../buildtmp install || ninja -C ../buildtmp install
rm -rf ../buildtmp
cd /tmp/
echo "#!/bin/sh
echo -e \"Copying files to their correct destinations...\"
echo -e \"The system may ask you for sudo password in order to install Ricin.\"
sudo cp -r -f share/ /usr/share/
sudo cp -f bin/Ricin /usr/bin/Ricin
echo -e \"Ricin static binary was installed!\"
exit 0" >> ricin/install.sh
chmod +x ricin/install.sh
tar czf ricin.tar.gz ricin
mv ricin.tar.gz "$curdir"
rm -rf ricin
