TEMPLATE = app

TARGET = harbour-kitchentimer
CONFIG += sailfishapp

#QT += declarative

SOURCES += $${TARGET}.cpp \
    qmlsettings.cpp

HEADERS += qmlsettings.h

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}
