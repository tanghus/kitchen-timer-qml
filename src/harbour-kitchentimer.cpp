/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Copyright 2013 Jolla Ltd.
** Contact: http://www.qt-project.org/legal
** Contact: Lorn Potter <lorn.potter@jollamobile.com>
** Copyright 2014 Thomas Tanghus
** Contact: Thomas Tanghus <thomas@tanghus.net>
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia. For licensing terms and
** conditions see http://qt.digia.com/licensing. For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights. These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file. Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>

#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QLocale>
#include <QTimer>
#include <QTranslator>
#include <QDebug>

#include "insomnia.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    //return SailfishApp::main(argc, argv);

    //QGuiApplication* app = SailfishApp::application(argc, argv);
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QQuickView* view = SailfishApp::createView();
    QTranslator *translator = new QTranslator;
    Insomnia *insomniac = new Insomnia();
    insomniac->setInterval(5);
    insomniac->setTimerWindow(10);

    QString locale = QLocale::system().name();

    qDebug() << "Translations:" << SailfishApp::pathTo("translations").toLocalFile() + "/" + locale + ".qm";

    if(!translator->load(SailfishApp::pathTo("translations").toLocalFile() + "/" + locale + ".qm")) {
        qDebug() << "Couldn't load translation";
    }
    app->installTranslator(translator);

    view->rootContext()->setContextProperty("insomniac", insomniac);
    view->setSource(SailfishApp::pathTo("qml/harbour-kitchentimer.qml"));
    view->showFullScreen();
    return app->exec();
}

