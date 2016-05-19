#! /usr/bin/env python
# encoding: utf-8
# SkyzohKey, 2016

from waflib import Utils

# the following two variables are used by the target "waf dist"
VERSION = '0.1.0'
APPNAME = 'ricin'

# these variables are mandatory ('/' are converted automatically)
top = '.'
out = 'build'

def options(opt):
	opt.load('compiler_c vala')
	opt.add_option('--enable-docs', action='store_true', default=False, help='Generate user documentation')
	opt.add_option('--enable-text-view', action='store_true', default=False, help='Enable use of GtkTextView to display messages')
	#opt.recurse('tests')

def configure(conf):
	conf.load('compiler_c vala gnu_dirs intltool glib2')
	conf.check_vala(min_version=(0, 28, 0))
	conf.check_cfg(package='glib-2.0', uselib_store='GLIB', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gio-2.0', uselib_store='GIO', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gobject-2.0', uselib_store='GOBJECT', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gmodule-2.0', uselib_store='GMODULE', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gtk+-3.0', uselib_store='GTK3', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='libsoup-2.4', uselib_store='SOUP', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='json-glib-1.0', uselib_store='JSONGLIB', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='libnotify', uselib_store='NOTIFY', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='libtoxcore', uselib_store='TOXCORE', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='libtoxencryptsave', uselib_store='TOXES', mandatory=1, args='--cflags --libs')

	# C compiler flags.
	conf.env.append_unique('CFLAGS', [
		'-Wall',
		'-Wno-deprecated-declarations',
		'-Wno-unused-variable',
		'-Wno-unused-but-set-variable',
		'-Wno-unused-function',
		'-DGETTEXT_PACKAGE="ricin"'
	])
	# Vala compiler flags.
	conf.env.append_unique('VALAFLAGS', [
		'--enable-experimental',
		'--enable-deprecated',
		#'--fatal-warnings'
	])

	#conf.recurse('res tests')

	if conf.options.enable_docs:
		conf.env.ENABLE_DOCS = True
		conf.recurse('docs')

	# TODO: Add a way to enable this.
	if conf.options.enable_text_view:
		conf.env.ENABLE_TEXT_VIEW = True

def build(bld):
	bld.load('compiler_c vala')
	#bld.recurse('src')
	#bld.recurse('tests')

	if bld.env.ENABLE_DOCS:
		bld.recurse('docs')

	# TODO: Add a way to enable this.
	if bld.env.ENABLE_TEXT_VIEW:
		pass

	if bld.cmd == 'install':
		try:
			bld.exec_command(["update-mime-database", Utils.subst_vars("${DATADIR}/mime", bld.env)])
			bld.exec_command(["update-desktop-database", Utils.subst_vars("${DATADIR}/applications", bld.env)])
		except:
			pass

	# Lang files
	langs = bld(
		features     = 'intltool_po',
		appname      = APPNAME,
		podir        = 'po',
		install_path = "${LOCALEDIR}"
	)

	# Desktop file
	desktop = bld(
		features     = "intltool_in",
		podir        = "po",
		style        = "desktop",
		source       = 'res/ricin.desktop.in',
		target       = 'ricin.desktop',
		install_path = "${DATADIR}/applications",
	)

	# Resources file
	resource = bld(
		features = 'c glib2',
		use      = 'GLIB GIO GOBJECT',
		source   = 'res/ricin.gresource.xml',
		target   = 'ricinres'
    )

	# libtoxencryptsave.pc
	toxespc = bld(
		feature      = 'subst',
		source       = 'vapis/libtoxencryptsave.pc.in',
		target       = 'libtoxencryptsave.pc',
		install_path = '${DATADIR}/pkgconfig',
		PREFIX       = bld.env.PREFIX
	)

	# Ricin
	ricin = bld.program(
		appname          = APPNAME,
		features         = 'c cprogram glib2',
		use              = 'ricinres',
		packages         = 'glib-2.0 gio-2.0 gobject-2.0 gmodule-2.0 gtk+-3.0 libsoup-2.4 json-glib-1.0 libnotify libtoxcore libtoxencryptsave',
		uselib           = 'GLIB GIO GOBJECT GMODULE GTK3 SOUP JSONGLIB NOTIFY TOXCORE TOXES',
		vala_target_glib = '2.38',
		source           = bld.path.ant_glob('src/*.vala'),
		vapi_dirs        = 'vapis',
		vala_resources   = 'res/ricin.gresource.xml',
		valaflags        = '--generate-source',
		target           = 'Ricin',
		install_binding  = False,
		header_path      = None,
		install_path     = "${BINDIR}"
	)
