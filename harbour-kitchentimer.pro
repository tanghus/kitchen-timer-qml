# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-kitchentimer

#CONFIG += sailfishapp

#CONFIG += link_pkgconfig
#PKGCONFIG += sailfishapp
#INCLUDEPATH += /usr/include/sailfishapp

#TARGETPATH = /usr/bin
#target.path = $${TARGETPATH}

DEPLOYMENT_PATH = /usr/share/$${TARGET}
qml.files = qml
qml.path = $${DEPLOYMENT_PATH}

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications

icon.files = $${TARGET}.png
icon.path = /usr/share/icons/hicolor/86x86/apps

sounds.files = sounds
sounds.path = $${DEPLOYMENT_PATH}

lupdate_only{
SOURCES = \
    ../qml/pages/TimerPage.qml \
    ../qml/pages/TimersDialog.qml \
    ../qml/pages/AboutPage.qml \
    ../qml/cover/CoverPage.qml \
    ../qml/pages/SoundDialog.qml \
    ../qml/pages/SoundSelectDialog.qml
}

CONFIG += sailfishapp_i18n
TRANSLATIONS = translations/ca.ts \
    translations/da_DK.ts \
    translations/de_DE.ts \
    translations/el.ts \
    translations/en_GB.ts \
    translations/es.ts \
    translations/fi_FI.ts \
    translations/fr.ts \
    translations/gl.ts \
    translations/hu_HU.ts \
    translations/it_IT.ts \
    translations/nb.ts \
    translations/nl.ts \
    translations/pl_PL.ts \
    translations/ru.ts \
    translations/sl_SI.ts \
    translations/sv.ts \
    translations/zh_CN.ts

translations.files = translations
translations.path = $${DEPLOYMENT_PATH}

OTHER_FILES += qml/*.qml \
    qml/cover/*.qml \
    qml/components/*.qml \
    js/*.js \
    rpm/*.spec \
    rpm/harbour-kitchentimer.yaml \
    LICENSE \
    README.md \
    Changelog

#PKGCONFIG += libiphb // Waiting for this to be allowed.

INSTALLS += desktop icon qml sounds translations

TEMPLATE = subdirs
SUBDIRS = src/insomniac src/folderlistmodel src



