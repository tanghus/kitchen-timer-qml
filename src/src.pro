TEMPLATE = app

TARGET = harbour-kitchentimer

# App version
DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

CONFIG += sailfishapp

#QT += declarative

SOURCES += $${TARGET}.cpp \
    qmlsettings.cpp

HEADERS += qmlsettings.h

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}
