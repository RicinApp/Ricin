ricin:
	valac \
		-g \
		-X -fsanitize=address \
		--vapidir=tox-vapi/vapi/ \
		--target-glib=2.32 \
		--pkg=gio-2.0 \
		--pkg=gtk+-3.0 \
		--pkg=libsoup-2.4 \
		--pkg=json-glib-1.0 \
		--pkg=libtoxcore \
		src/Ricin.vala \
		src/MainWindow.vala \
		src/ProfileChooser.vala \
		src/Util.vala
