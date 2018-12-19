# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-kitchentimer

# >> macros
%define __provides_exclude_from ^%{_datadir}/.*$
# list here all the libraries your RPM installs
%define __requires_exclude ^libinsomniac|libQt5Declarative|libc.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Kitchen Timer
Version:    0.2.1
Release:    2
Group:      Qt/Qt
License:    BSD
URL:        https://github.com/tanghus/kitchen-timer-qml
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-kitchentimer.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  desktop-file-utils

%description
Very simple kitchen timer


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5  \
    VERSION=%{version}

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}
%{_datadir}/%{name}
%{_datadir}/%{name}/lib/harbour/kitchentimer/insomniac
%{_datadir}/%{name}/lib/harbour/kitchentimer
%{_datadir}/%{name}/lib/harbour
%{_datadir}/%{name}/translations
%{_datadir}/%{name}/qml
%{_datadir}/%{name}/sounds
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
%{_bindir}/%{name}
%{_bindir}
# >> files
# << files
