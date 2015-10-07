ricin:
	valac \
		-g \
		-X -fsanitize=address \
		--vapidir=tox-vapi/vapi/ \
		--pkg=gio-2.0 \
		--pkg=gtk+-3.0 \
		--pkg=libsoup-2.4 \
		--pkg=json-glib-1.0 \
		src/Ricin.vala
