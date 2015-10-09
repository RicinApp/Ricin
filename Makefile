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
		-o Ricin \
		src/*.vala

style:
	astyle \
		--style=attach \
		--indent=spaces=2 \
		--indent-namespaces \
		--indent-switches \
		--add-one-line-brackets \
		src/*.vala

debug: ricin
	G_MESSAGES_DEBUG=all GOBJECT_DEBUG=instance-count ./Ricin
