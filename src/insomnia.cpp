/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Copyright 2013 Jolla Ltd.
** Contact: http://www.qt-project.org/legal
** Contact: Lorn Potter <lorn.potter@jollamobile.com>
**
** Originally from https://github.com/lpotter/libalignedtimer/
** Modified by Thomas Tanghus
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

#include "insomnia.h"
#include <QDebug>

#include <errno.h>
#include <stdio.h>


Insomnia::Insomnia(QObject *parent) :
    QObject(parent)
  , m_interval(0)
  , m_timerWindow(120)
  , m_running(false)
  , m_singleShot(false)
  , m_iphbdHandler(0)
  , m_notifier(0)
{
    m_iphbdHandler = iphb_open(0);

    if (!m_iphbdHandler) {
        m_lastError = Insomnia::InternalError;
        qDebug() << "iphb_open error" << m_iphbdHandler<< errno <<strerror(errno);
        return;
    }

    int sockfd = iphb_get_fd(m_iphbdHandler);
    if (!(sockfd > -1)) {
        m_lastError = Insomnia::InternalError;
        qDebug() << "socket failure"<<strerror(errno);
        return;
    }

    m_notifier = new QSocketNotifier(sockfd, QSocketNotifier::Read);
    if (!QObject::connect(m_notifier, SIGNAL(activated(int)), this, SLOT(heartbeatReceived(int)))) {
        delete m_notifier, m_notifier = 0;
        m_lastError = Insomnia::TimerFailed;
        qDebug() << "timer failure";
        return;
    }
    m_notifier->setEnabled(false);
}

Insomnia::~Insomnia()
{
    if (m_iphbdHandler)
        (void)iphb_close(m_iphbdHandler);

    if (m_notifier)
        delete m_notifier;
}

void Insomnia::wokeUp()
{
    if (!m_running)
        return;

    if (!(m_iphbdHandler && m_notifier)) {
        m_lastError = Insomnia::InternalError;
        emit error(m_lastError);
        return;
    }

    m_notifier->setEnabled(false);

    (void)iphb_I_woke_up(m_iphbdHandler);

    m_running = false;
    m_lastError = Insomnia::NoError;

    start();
}

int Insomnia::interval() const
{
    return m_interval;
}

void Insomnia::setInterval(int seconds)
{
    m_interval = seconds;
}

void Insomnia::setSingleShot(bool singleShot)
{
    m_singleShot = singleShot;
}

bool Insomnia::isSingleShot() const
{
    return m_singleShot;
}

/*!
This static function starts a timer to call a slot around \a interval
interval has elapsed, and ensures that it will be called within the
\a timeWindow amount of time.

These values are specified in seconds. Default timeWindow is 120 seconds

The receiver is the \a receiver object and the \a member is the slot.
*/
void Insomnia::singleShot(int interval, QObject *receiver, const char *member, int timeWindow)
{
    if (receiver && member) {
        Insomnia *insomniac = new Insomnia(receiver);
        insomniac->m_singleShot = true;

        connect(insomniac, SIGNAL(timeout()), receiver, member);
        insomniac->start(interval, timeWindow);
    }
}

int Insomnia::timerWindow() const
{
    return m_timerWindow;
}

void Insomnia::setTimerWindow(int seconds)
{
    m_timerWindow = seconds;
}

void Insomnia::start(int interval, int timeWindow)
{
    m_interval = interval;
    m_timerWindow = timeWindow;

    start();
}

void Insomnia::start()
{
    if (m_running)
        return;

    if (!(m_iphbdHandler && m_notifier)) {
        m_lastError = Insomnia::InternalError;
        emit error(m_lastError);
        return;
    }

    int mustWait = 0;
    time_t unixTime = iphb_wait(m_iphbdHandler, m_interval - (m_timerWindow * .5)
                                , m_interval + (m_timerWindow * .5) , mustWait);

    if (unixTime == (time_t)-1) {
        m_lastError = Insomnia::TimerFailed;
        emit error(m_lastError);
        return;
    }

    m_notifier->setEnabled(true);
    m_running = true;
    m_lastError = Insomnia::NoError;
}

void Insomnia::stop()
{
    if (!m_running)
        return;

    if (!(m_iphbdHandler && m_notifier)) {
        m_lastError = Insomnia::InternalError;
        emit error(m_lastError);
        return;
    }

    m_notifier->setEnabled(false);

    (void)iphb_discard_wakeups(m_iphbdHandler);

    m_running = false;
    m_lastError = Insomnia::NoError;
}

void Insomnia::heartbeatReceived(int sock) {
    Q_UNUSED(sock);

    stop();
    emit timeout();

    if (!m_singleShot) {
        start();
    }
}

bool Insomnia::isActive() const
{
    return m_running;
}
