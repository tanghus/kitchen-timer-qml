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

#ifndef INSOMNIA_H
#define INSOMNIA_H

#include <QObject>
#include <QSocketNotifier>

extern "C" {
#include <iphbd/libiphb.h>
}

class Insomnia : public QObject
{
    Q_OBJECT
public:
    explicit Insomnia(QObject *parent = 0);
    ~Insomnia();

    enum InsomniaError {
        NoError = 0,
        AlignedTimerNotSupported,
        InvalidArgument,
        TimerFailed,
        InternalError
    };

public:
    void wokeUp();

    int interval() const;
    void setInterval(int seconds);

    int timerWindow() const;
    void setTimerWindow(int seconds);

    InsomniaError lastError() const;
    bool isActive() const;
    Insomnia::InsomniaError m_lastError;

Q_SIGNALS:
    void timeout();
    void error(Insomnia::InsomniaError error);

private:
    int m_interval;
    int m_timerWindow;
    bool m_running;
    bool m_singleShot;
    iphb_t m_iphbdHandler;
    QSocketNotifier *m_notifier;

public Q_SLOTS:
    void start(int interval, int timerWindow);
    void start();
    void stop();

private Q_SLOTS:
    void heartbeatReceived(int sock);
};

#endif // INSOMNIA_H
