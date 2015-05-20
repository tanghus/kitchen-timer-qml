#ifndef INSOMNIAC_H
#define INSOMNIAC_H

#include <QQuickItem>
#include <QSocketNotifier>

extern "C" {
#include "libiphb/libiphb.h"
}

class Insomniac : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(Insomniac)

public:
    Insomniac(QQuickItem *parent = 0);
    ~Insomniac();

    Q_PROPERTY(int timerWindow READ timerWindow WRITE setTimerWindow)
    Q_PROPERTY(bool repeat READ repeat WRITE setRepeat)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(int interval READ interval WRITE setInterval)

    enum InsomniacError {
        NoError = 0,
        InvalidArgument,
        TimerFailed,
        InternalError
    };

    Insomniac::InsomniacError m_lastError;
    InsomniacError lastError() const;

    void wokeUp();

    int interval() const;
    void setInterval(int seconds);

    int timerWindow() const;
    void setTimerWindow(int seconds);

    bool repeat() const;
    void setRepeat(bool repeat);

    bool running() const;

Q_SIGNALS:
    void runningChanged();
    void timeout();
    void error(Insomniac::InsomniacError error);

private:
    int m_interval;
    int m_timerWindow;
    bool m_running;
    bool m_repeat;
    iphb_t m_iphbdHandler;
    QSocketNotifier *m_notifier;

public Q_SLOTS:
    Q_INVOKABLE void start(int interval, int timerWindow);
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();

private Q_SLOTS:
    void heartbeatReceived(int sock);
};

#endif // INSOMNIAC_H

