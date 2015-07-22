TARGET = folderlistmodel
PROJECT = kitchentimer
PLUGIN_IMPORT_PATH = harbour/kitchentimer/folderlistmodel

TEMPLATE = lib
CONFIG += qt plugin hide_symbols

QT += qml
QT -= gui
#    target.path = $$[QT_INSTALL_QML]/$$PLUGIN_IMPORT_PATH
#    qmldir.path +=  $$[QT_INSTALL_QML]/$$$$PLUGIN_IMPORT_PATH

TARGET = $$qtLibraryTarget($$TARGET)
target.path = /usr/share/harbour-$$PROJECT/lib/harbour/$$PROJECT/folderlistmodel

OTHER_FILES = qmldir

qmldir.files += $$_PRO_FILE_PWD_/qmldir
qmldir.path += $$target.path

INSTALLS += target qmldir

SOURCES += plugin.cpp \
           dirmodel.cpp \
           iorequest.cpp \
           iorequestworker.cpp \
           ioworkerthread.cpp

HEADERS += plugin.h \
           dirmodel.h \
           iorequest.h \
           iorequestworker.h \
           ioworkerthread.h

