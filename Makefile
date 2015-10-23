style:
	astyle \
		--style=attach \
		--indent=spaces=2 \
		--indent-namespaces \
		--indent-switches \
		--add-brackets \
		src/*.vala

debug: ./build/Ricin
	G_MESSAGES_DEBUG=all GOBJECT_DEBUG=instance-count gdb -ex run ./build/Ricin
