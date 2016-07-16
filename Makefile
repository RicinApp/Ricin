.PHONY: autogen build debug install style nodesfile pot changelog reset-settings

autogen:
	./waf distclean
	./waf configure --prefix=/usr/

build:
	./waf build

debug: build
	G_MESSAGES_DEBUG=all GOBJECT_DEBUG=instance-count gdb -ex run ./build/Ricin

install: build
	./waf install

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
