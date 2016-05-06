# vim: set ft=python
project(
    'Ricin',
    'vala',
    'c', # compiling vala requires a C compiler
    meson_version: '>=0.31.0'
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
    dependency('libtoxcore')
]

subdir('src')
subdir('res')

# GetText stuff.
add_global_arguments('-DGETTEXT_PACKAGE="ricin"', language : 'c')
add_global_arguments('-O3', language : 'c') # Optimise the output
subdir('po')

executable(
    'Ricin',
    sources: [ src, res ],
    dependencies: deps,
    vala_args: [
        '-g',
        '--gresources', resxml,
        '--vapidir', '@0@/@1@'.format(meson.current_source_dir(), 'vapis/')
    ],
    #link_args : '-static',
    install: true
)

install_data('res/ricin.desktop', install_dir: 'share/applications/')
install_data('res/images/icons/ricin.svg', install_dir: 'share/icons/')
