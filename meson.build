# vim: set ft=python
project('Ricin',
    'vala',
    'c', # compiling vala requires a C compiler
)
gnome = import('gnome')
rpm   = import('rpm')

deps = [
    dependency('glib-2.0', version: '>=2.38'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('gmodule-2.0'),
    dependency('gtk+-3.0'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    dependency('libnotify'),
    dependency('libtoxcore')
]

libconfig = dependency('libconfig', required : false)
if libconfig.found()
    deps += libconfig # Needed cuz Windows won't use libconfig.
endif

subdir('src')
subdir('res')

# GetText stuff.
add_global_arguments('-DGETTEXT_PACKAGE="ricin"', language : 'c')
subdir('po')

executable(
    'Ricin',
    sources: [ src, res ],
    dependencies: deps,
    vala_args: [
        '-g',
        '--gresources', resxml,
        '--vapidir', '@0@/@1@'.format(meson.current_source_dir(), 'tox-vapi/vapi/'),
    ],
    install: true
)

install_data('ricin.desktop', install_dir: 'share/applications/')
install_data('icons/Ricin-128x128.png', install_dir: 'share/')

rpm.generate_spec_template()
