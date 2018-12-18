TEMPLATE = lib
PROJECT = kitchentimer
TARGET = insomniac
QT += quick
QT -= gui
CONFIG += qt plugin
#LIBS += -liphb

TARGET = $$qtLibraryTarget($$TARGET)
target.path = /usr/share/harbour-$$PROJECT/lib/harbour/$$PROJECT/$$TARGET

uri = harbour.$$PROJECT.TARGET

# Input
SOURCES += \
    insomniac.cpp \
    insomniac_plugin.cpp \
    libiphb/libiphb.c

HEADERS += \
    insomniac.h \
    insomniac_plugin.h \
    libiphb/libiphb.h \
    libiphb/iphb_internal.h \
    libiphb/messages.h

OTHER_FILES = qmldir

qmldir.files += $$_PRO_FILE_PWD_/qmldir
qmldir.path += $$target.path

PKGCONFIG += libiphb

INSTALLS += target qmldir

