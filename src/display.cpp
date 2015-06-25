/*
  Copyright (C) 2015 Thomas Tanghus <thomas@tanghus.net>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <QDebug>
#include <QDBusMessage>
#include <QDBusReply>
#include <QDBusError>
#include "display.h"

static void checkError(QDBusMessage &msg) {
    if (msg.type() == QDBusMessage::ErrorMessage)
        qDebug() << msg.errorName() << msg.errorMessage();
}

Display::Display(QObject *parent) :
    QObject(parent),
    mceInterface("com.nokia.mce", "/com/nokia/mce/request", "com.nokia.mce.request",
                   QDBusConnection::systemBus()) {
}

void Display::unBlank() {
    //QDBusMessage reply = mceInterface.call("req_display_state_on");
    //QDBusMessage reply = mceInterface.call("req_call_state_change", "ringing", "normal");
    QDBusMessage reply = mceInterface.call("notification_begin_req", "kitchentimer", 15000, 2500);
    checkError(reply);
    QTimer::singleShot(10000, this, SLOT(timeOut()));
}

void Display::timeOut() {
    QDBusMessage reply = mceInterface.call("req_call_state_change", "none", "normal");
    checkError(reply);
}

bool Display::isLocked() {
    //QDBusReply<QString> reply = mceInterface.call("get_display_status");
    QDBusReply<QString> reply = mceInterface.call("get_tklock_mode");
    if (reply.isValid()) {
        qDebug() << "reply" << reply.value();
        if(reply.value() == "unlocked") {
            return false;
        } else {
            return true;
        }
    } else {
        QDBusError error = reply.error();
        qDebug() << error.name() << error.message();
        // returning true as state is unknown
        return true;
    }
}

void Display::unLock() {
    QDBusReply<QString> reply = mceInterface.call("req_tklock_mode_change", "unlocked");
    if(!reply.isValid()) {
        QDBusError error = reply.error();
        qDebug() << error.name() << error.message();
    }
}
