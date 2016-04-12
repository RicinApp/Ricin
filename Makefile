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

pot:
	xgettext --language=C --language=Glade \
	--keyword=_ --escape --sort-output \
	-o po/ricin.pot \
	src/*.vala \
	res/ui/*.ui

changelog:
	clog -T markdown -F -r https://github.com/RicinApp/Ricin -o docs/CHANGELOG.md

reset-settings:
	@echo -e "\e[93m\e[1mλ Deleting settings from ~/.config/tox/ricin.json\e[21m\e[39m"
	@rm -f ~/.config/tox/ricin.json
	@echo -e "\e[93m\e[1mλ Copying settings from ./res/ricin.sample.json to ~/.config/tox/ricin.json\e[21m\e[39m"
	@cp -f ./res/ricin.sample.json ~/.config/tox/ricin.json
	@echo -e "\e[93m\e[1mλ Succesfuly reset'd settings!\e[21m\e[39m"

autogen:
	rm -rf ./build
	mkdir -p ./build
	meson.py . ./build

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

install:
	cd build/ && type ninja-build 2>/dev/null && ninja-build install || ninja install


# Winshit stuff.
autogenwin:
	sudo rm -rf ./build-win32
	mkdir -p ./build-win32
	sudo meson.py . ./build-win32 --cross-file ./tools/cross_win.txt

debugwin:
	ninja-build -C build-win32 clean
	ninja-build -C build-win32
