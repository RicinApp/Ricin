# vim: set ft=python
project('Ricin',
    'vala',
    'c', # compiling vala requires a C copmiler
)
gnome = import('gnome')

deps = [
    dependency('glib-2.0', version: '>=2.38'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    dependency('libsoup-2.4'),
    dependency('libtoxcore'),
    dependency('libnotify'),
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
