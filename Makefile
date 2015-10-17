ricin:
	glib-compile-resources \
		--generate-source \
		--sourcedir=res/ \
		--target=resources.c \
		res/ricin.gresource.xml
	valac \
		-g \
		-X -ggdb \
		-X -fsanitize=address \
		--vapidir=tox-vapi/vapi/ \
		--target-glib=2.38 \
		--pkg=gio-2.0 \
		--pkg=gtk+-3.0 \
		--pkg=libsoup-2.4 \
		--pkg=json-glib-1.0 \
		--pkg=libtoxcore \
		--gresources=res/ricin.gresource.xml \
		-o Ricin \
		src/*.vala \
		resources.c

style:
	astyle \
		--style=attach \
		--indent=spaces=2 \
		--indent-namespaces \
		--indent-switches \
		--add-brackets \
		src/*.vala

clean:
	-rm res/*.ui~
	-rm res/#*.ui#

debug: ricin
	G_MESSAGES_DEBUG=all GOBJECT_DEBUG=instance-count gdb -ex run ./Ricin
