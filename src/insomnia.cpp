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

    start();
}

bool Insomnia::isActive() const
{
    return m_running;
}
