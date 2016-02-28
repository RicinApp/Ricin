# vim: set ft=python
project('Ricin',
    'vala',
    'c', # compiling vala requires a C compiler
)
gnome = import('gnome')

deps = [
    dependency('glib-2.0', version: '>=2.38'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('gmodule-2.0'),
    dependency('gtk+-3.0'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    dependency('libnotify'),
    dependency('libtoxcore'),
]

subdir('src')
subdir('res')

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

install_data('misc/ricin.desktop', install_dir: '/usr/share/applications/')
install_data('res/images/icons/Ricin-128x128.png', install_dir: '/usr/share/icons/')
