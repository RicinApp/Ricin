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
	
install: ./build/
	type ninja-build 2>/dev/null && ninja-build -C build || ninja -C build
	mv build/Ricin /usr/bin/Ricin

debugwin:
	valac \
		--cc=x86_64-w64-mingw32-gcc \
		--target-glib=2.38 \
		--vapidir=./tox-vapi/vapi \
		--gresources=./res/ricin.gresource.xml \
		--pkg glib-2.0 \
		--pkg gio-2.0 \
		--pkg gobject-2.0 \
		--pkg gtk+-3.0 \
		--pkg json-glib-1.0 \
		--pkg libsoup-2.4 \
		--pkg libtoxcore \
		--pkg libnotify \
		-o build/Ricin.exe \
		src/*.vala
