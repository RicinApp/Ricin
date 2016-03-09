style:
	astyle \
		--style=attach \
		--indent=spaces=2 \
		--indent-namespaces \
		--indent-switches \
		--add-brackets \
		src/*.vala

nodesfile:
	wget -O res/nodes.json https://build.tox.chat/job/nodefile_build_linux_x86_64_release/lastSuccessfulBuild/artifact/Nodefile.json

# not needed when we get meson 0.27.0
cleandebug:
	type ninja-build 2>/dev/null && ninja-build -C build clean || ninja -C build clean
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build
	G_MESSAGES_DEBUG=all GOBJECT_DEBUG=instance-count gdb -ex run ./build/Ricin

debug: ./build/
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build
	G_MESSAGES_DEBUG=all GOBJECT_DEBUG=instance-count gdb -ex run ./build/Ricin

cleanrelease:
	type ninja-build 2>/dev/null && ninja-build -C build clean || ninja -C build clean
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build

release: ./build/
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build

# This need to be rewritted using ninja install to work on all systems.
install: ./build/
	type ninja-build 2>/dev/null && ninja-build -C build clean || ninja -C build clean
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build
	sudo cp "build/Ricin" "/usr/bin/Ricin" # Binary
	sudo cp "misc/ricin.desktop" "/usr/share/applications/ricin.desktop" # Desktop file
	sudo cp "res/images/icons/Ricin-128x128.png" "/usr/share/icons/Ricin-128x128.png" # Icon
	sudo cp "po/en_US.mo" "/usr/share/locale/en_US/LC_MESSAGES/ricin.mo" # English
	sudo cp "po/fr_FR.mo" "/usr/share/locale/fr_FR/LC_MESSAGES/ricin.mo" # French
	sudo cp "po/pt_PT.mo" "/usr/share/locale/pt_PT/LC_MESSAGES/ricin.mo" # Portuguese
	sudo cp "po/da_DK.mo" "/usr/share/locale/da_DK/LC_MESSAGES/ricin.mo" # Danish

autogenwin:
	sudo /usr/bin/meson . build-win32 --cross-file cross_win.txt

debugwin:
	ninja-build -C build-win32 clean
	ninja-build -C build-win32
