/*
  Copyright (C) 2013 Thomas Tanghus
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"
import "components"

ApplicationWindow {

    id: app;

    property string timeText: '00:01';
    property bool isBusy: false;
    property alias isPlaying: timerPage.isPlaying;
    property alias isRunning: timerPage.isRunning;
    property alias seconds: timerPage.seconds;
    property alias minutes: timerPage.minutes;

    initialPage: TimerPage {
        id: timerPage;
    }

    cover: CoverPage {
        id: cover;
    }

    BusyIndicator {
        id: busyIndicator;
        anchors.centerIn: parent;
        size: BusyIndicatorSize.Large;
    }

    ListModel {
        id: timersModel;
    }

    Component.onCompleted: {
        load();
    }

    Storage {
        id: storage;
        dbName: StandardPaths.data;
    }

    Connections {
        target: cover;
        onMute: timerPage.mute();
        onPause: timerPage.pause();
        onReset: timerPage.reset();
        onStart: timerPage.start();
    }

    function save() {
        console.log('Saving...');
        setBusy(true);
        var timers = [];

        for (var i = 0; i < timersModel.count; ++i) {
            var timer = timersModel.get(i);
            timers.push({name:timer.name, minutes: timer.minutes, seconds:timer.seconds});
        }

        storage.saveTimers(timers);
        setBusy(false);
    }

    function load() {
        setBusy(true);
        var timers = storage.getTimers();

        if(timers === false) {
            console.warn('Default timers could not be loaded');
            setBusy(false);
            return
        }

        for (var i = 0; i < timers.length; ++i) {
            timersModel.append(
                {
                    name: timers[i].name,
                    minutes: timers[i].minutes,
                    seconds: timers[i].seconds
                }
            );
        }
        setBusy(false);
    }

    function reload() {
        timersModel.clear();
        load();
        console.log('Reloading...');
    }

    function setBusy(state) {
        isBusy = state;
        busyIndicator.running = state;
    }
}


