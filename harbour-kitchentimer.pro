# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
#TARGET = harbour-kitchentimer

#CONFIG += sailfishapp

#QT += quick declarative

#QT += quick qml
#CONFIG += link_pkgconfig
#PKGCONFIG += sailfishapp
#INCLUDEPATH += /usr/include/sailfishapp

#TARGETPATH = /usr/bin
#target.path = $${TARGETPATH}

DEPLOYMENT_PATH = /usr/share/$${TARGET}
#qml.files = qml
#qml.path = $${DEPLOYMENT_PATH}

#desktop.files = $${TARGET}.desktop
#desktop.path = /usr/share/applications

#icon.files = $${TARGET}.png
#icon.path = /usr/share/icons/hicolor/86x86/apps

sounds.files = sounds
sounds.path = $${DEPLOYMENT_PATH}

#SOURCES += src/$${TARGET}.cpp

translations.files = translations
translations.path = $${DEPLOYMENT_PATH}

OTHER_FILES += qml/harbour-kitchentimer.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-kitchentimer.spec \
    rpm/harbour-kitchentimer.yaml \
    harbour-kitchentimer.desktop \
    qml/pages/TimerPage.qml \
    qml/pages/TimersDialog.qml \
    qml/pages/AboutPage.qml \
    qml/components/KitchenTimer.qml \
    qml/components/Storage.qml \
    js/Storage.js \
    LICENSE \
    README.md \
    .travis.yml \
    transifex.sh \
    Changelog

#PKGCONFIG += libiphb

INSTALLS += sounds translations

TEMPLATE = subdirs
SUBDIRS = src/insomniac src translations



