pot:
	xgettext --language=C --language=Glade \
	--keyword=_ --escape --sort-output \
	-o data/languages/ricin-messenger.pot \
	src/*.vala \
	src/*/*.vala \
	#data/gui/*.ui
