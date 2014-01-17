#ifndef INSOMNIAC_PLUGIN_H
#define INSOMNIAC_PLUGIN_H

#include <QQmlExtensionPlugin>

class InsomniacPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif // INSOMNIAC_PLUGIN_H

