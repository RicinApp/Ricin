Name:           Ricin
Version:        0.0.4
Release:        1%{?dist}
Summary:        A dead-simple but powerful Tox client.

License:        GPLv3
URL:            https://ricin.im
Source0:        https://ricin.im/static/cdn/Ricin-0.0.4.tar.gz
Source10:       %{name}.desktop

BuildRequires:  vala
BuildRequires:  gcc
BuildRequires:  gettext
BuildRequires:  desktop-file-utils
BuildRequires:  glib2
BuildRequires:  meson
BuildRequires:  Libmarkdown-devel

Requires:  libconfig
Requires:  tox-libtoxcore
Requires:  gtk3
Requires:  json-glib
Requires:  libsoup
Requires:  libnotify
Requires:  libmarkdown

%description

%prep
%autosetup
rm -rf rpmbuilddir && mkdir rpmbuilddir

%build
pushd rpmbuilddir
  %meson ..
  ninja-build -v
popd

%install
pushd rpmbuilddir
  DESTDIR=%{buildroot} ninja-build -v install
popd
desktop-file-install --vendor="" \
  --dir=%{buildroot}%{_datadir}/applications/ \
  %{buildroot}%{_datadir}/applications/ricin.desktop

%check
pushd rpmbuilddir
  ninja-build -v test
popd

%find_lang ricin

%files
%{_bindir}/Ricin
%{_datadir}/icons/
%{_datadir}/locale/
%{_datadir}/applications/

%changelog
* Wed Apr 6 2016 SkyzohKey <skyzohkey@protonmail.com> -
-
