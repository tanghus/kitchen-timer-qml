#include "insomniac.h"
#include <QDebug>

#include <errno.h>
#include <stdio.h>

Insomniac::Insomniac(QQuickItem *parent):
    QQuickItem(parent)
  , m_interval(0)
  , m_timerWindow(120)
  , m_running(false)
  , m_repeat(true)
  , m_iphbdHandler(0)
  , m_notifier(0)
{
    m_iphbdHandler = iphb_open(0);

    if (!m_iphbdHandler) {
        m_lastError = Insomniac::InternalError;
        qDebug() << "iphb_open error" << m_iphbdHandler<< errno <<strerror(errno);
        return;
    }

    int sockfd = iphb_get_fd(m_iphbdHandler);
    if (!(sockfd > -1)) {
        m_lastError = Insomniac::InternalError;
        qDebug() << "socket failure"<<strerror(errno);
        return;
    }

    m_notifier = new QSocketNotifier(sockfd, QSocketNotifier::Read);
    if (!QObject::connect(m_notifier, SIGNAL(activated(int)), this, SLOT(heartbeatReceived(int)))) {
        delete m_notifier, m_notifier = 0;
        m_lastError = Insomniac::TimerFailed;
        qDebug() << "timer failure";
        return;
    }
    m_notifier->setEnabled(false);
}

Insomniac::~Insomniac()
{
    if(m_iphbdHandler) {
        (void)iphb_close(m_iphbdHandler);
    }

    if(m_notifier) {
        delete m_notifier;
    }
}

void Insomniac::wokeUp()
{
    if (!m_running)
        return;

    if (!(m_iphbdHandler && m_notifier)) {
        m_lastError = Insomniac::InternalError;
        emit error(m_lastError);
        return;
    }

    m_notifier->setEnabled(false);

    (void)iphb_I_woke_up(m_iphbdHandler);

    m_running = false;
    emit runningChanged();
    m_lastError = Insomniac::NoError;

    start();
}

int Insomniac::interval() const
{
    return m_interval;
}

void Insomniac::setInterval(int seconds)
{
    m_interval = seconds;
}

void Insomniac::setRepeat(bool repeat)
{
    m_repeat = repeat;
}

bool Insomniac::repeat() const
{
    return m_repeat;
}

int Insomniac::timerWindow() const
{
    return m_timerWindow;
}

/**
Sets the timer's timeout window in seconds.

The timeout window is a window of time set around the interval in which the timer will timeout.

It is wise to have timeout window quite big so all users of this service get synced.

For example if your preferred wait is 120 seconds and you can wait anywhere within 10 seconds,
use interval of 120 and timerWindow of 10. This means the timer will timeout anywhere from
115 seconds to 125 seconds.

*/
void Insomniac::setTimerWindow(int seconds)
{
    m_timerWindow = seconds;
}

void Insomniac::start(int interval, int timeWindow)
{
    m_interval = interval;
    m_timerWindow = timeWindow;

    start();
}

void Insomniac::start()
{
    if (m_running) {
        return;
    }

    if (!(m_iphbdHandler && m_notifier)) {
        m_lastError = Insomniac::InternalError;
        emit error(m_lastError);
        return;
    }

    int mustWait = 0;
    time_t unixTime = iphb_wait(m_iphbdHandler, m_interval - (m_timerWindow * .5)
                                , m_interval + (m_timerWindow * .5) , mustWait);

    if (unixTime == (time_t)-1) {
        m_lastError = Insomniac::TimerFailed;
        emit error(m_lastError);
        return;
    }

    m_notifier->setEnabled(true);
    m_running = true;
    emit runningChanged();
    m_lastError = Insomniac::NoError;
}

void Insomniac::stop()
{
    if (!m_running) {
        return;
    }

    if (!(m_iphbdHandler && m_notifier)) {
        m_lastError = Insomniac::InternalError;
        emit error(m_lastError);
        return;
    }

    m_notifier->setEnabled(false);

    (void)iphb_discard_wakeups(m_iphbdHandler);

    m_running = false;
    emit runningChanged();
    m_lastError = Insomniac::NoError;
}

void Insomniac::heartbeatReceived(int sock) {
    Q_UNUSED(sock);

    stop();
    emit timeout();

    if (m_repeat) {
        start();
    }
}

bool Insomniac::running() const
{
    return m_running;
}

