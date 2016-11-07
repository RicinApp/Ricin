#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals
import os
import fnmatch

AUTHOR = u'SkyzohKey <skyzohkey@framasphere.org>'
SITENAME = u'Ricin'
SITEURL = u'https://ricin.im'
TAG_LINE = u'Dead simple, privacy oriented, instant messaging app!'

PATH = 'content'
TIMEZONE = 'UTC'

DEFAULT_LANG = 'en'
LOCALE = 'en_US.UTF-8'

FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None

DEFAULT_PAGINATION = False

THEME = 'themes/default'

PLUGIN_PATHS = ['plugins']
PLUGINS = ['i18n_subsites']
JINJA_EXTENSIONS = ['jinja2.ext.i18n']

I18N_GETTEXT_DOMAIN = 'ricin_im'
I18N_GETTEXT_LOCALEDIR = os.path.join(THEME, 'translations')
I18N_SUBSITES = {
    'fr': {
        'SITENAME': 'Ricin',
        'AUTHOR': 'SkyzohKey <skyzohkey@framasphere.org>',
        'LOCALE': 'fr.UTF-8',
    },
    'ru': {
        'SITENAME': 'Ricin',
        'AUTHOR': 'Ingvar',
        'LOCALE': 'ru_RU.UTF-8'
    },
}

languages_lookup = {
    'en': 'English',
    'fr': 'Français',
    'ru': 'Русский',
}

def lookup_lang_name(lang_code):
    return languages_lookup[lang_code]

JINJA_FILTERS = {
    'lookup_lang_name': lookup_lang_name,
}

# pelican is mainly aimed at blogs and a regular pelican template has only
# a predefined set of files with predefined names which do blog things.
# since we don't need blog things, we override that, making pelican process
# all template files (that don't start with '_') and don't treat them as some
# special blog templates.
DIRECT_TEMPLATES = []
TEMPLATE_PAGES = {}

templates_dir = THEME + '/templates'
for root, dirnames, filenames in os.walk(templates_dir):
    for filename in fnmatch.filter(filenames, '*.html'):
        if not filename.startswith("_"):
            template = os.path.join(root, filename)[len(templates_dir)+1:]
            TEMPLATE_PAGES[template] = template

