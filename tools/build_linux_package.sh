#!/bin/sh
# Linux .tar.gz build maker

curdir=`pwd`
tmpdir="/tmp/ricin"

cd "$curdir"
./waf configure --exec-prefix="$tmpdir" --prefix="$tmpdir" --libdir=lib
./waf build --exec-prefix="$tmpdir" --prefix="$tmpdir" --libdir=lib

mkdir -p "$tmpdir"
./waf install --exec-prefix="$tmpdir" --prefix="$tmpdir" --libdir=lib

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

exit 0
