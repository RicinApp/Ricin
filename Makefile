release: ./build/
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build

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

install:
	cd build/ && type ninja-build 2>/dev/null && ninja-build install || ninja install

autogenwin:
	sudo /usr/bin/meson . build-win32 --cross-file cross_win.txt

debugwin:
	ninja-build -C build-win32 clean
	ninja-build -C build-win32
