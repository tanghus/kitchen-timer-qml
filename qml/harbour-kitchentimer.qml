/*
  Copyright (C) 2013 Thomas Tanghus
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
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import harbour.kitchentimer.insomniac 1.0
import "pages"
import "cover"
import "components"

ApplicationWindow {

    id: app;

    property string timeText: '00:01';
    property bool isBusy: false;
    // Close enough to assume screen is off.
    property bool viewable: cover.status ===  Cover.Active || applicationActive;
    property alias isPlaying: alarm.playing;
    property bool isRunning: timer.running || insomniac.running;
    property alias seconds: timerPage.seconds;
    property alias minutes: timerPage.minutes;
    property int lastTimerMin: -1;
    property int lastTimerSec: -1;
    property int _lastTick: 0;
    // Remaining time in seconds when screen blanks
    property int _remaining: 0;

    allowedOrientations: Orientation.Portrait | Orientation.Landscape; //defaultAllowedOrientations

    onViewableChanged: {
        if(!isRunning) {
            return;
        }

        if(viewable) {
            wakeUp();
        } else {
            snooze();
        }

    }

    Component.onCompleted: {
        load();
    }

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

    SoundEffect {
        id: alarm;
        loops: -2;
        source: Qt.resolvedUrl('../sounds/harbour-kitchentimer.wav');
    }

    Timer {
        id: timer;
        interval: 1000;
        running: false; repeat: true;
        /*onRunningChanged: {
            if (running === true) {
                console.log("Timer running");
            } else {
                console.log("Timer stopped");
            }
        }*/
        onTriggered: {
            var now = Math.round(Date.now()/1000);
            seconds -= now - _lastTick;
            _lastTick = now;
            //console.log('seconds', seconds);
            if(minutes === 0 && seconds === 0) {
                timer.stop();
                alarm.play();
            }
        }
    }

    Insomniac {
        id: insomniac;
        repeat: false;
        timerWindow: 10;
        onTimeout: {
            wakeUp();
        }
        onError: {
            console.warn('Error in wake-up timer');
        }
    }

    Storage {
        id: storage;
        dbName: StandardPaths.data;
    }

    Connections {
        target: cover;
        onMute: mute();
        onPause: pause();
        onReset: reset();
        onStart: start();
    }

    function save() {
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
    }

    function setBusy(state) {
        isBusy = state;
        busyIndicator.running = state;
    }
    function showTime() {
        timeText = Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), 'mm:ss');
    }

    function setTime(mins, secs) {
        console.log('setTime:', mins, secs);
        minutes = mins;
        seconds = secs;
    }

    function mute() {
        if(alarm.playing) {
            alarm.stop();
        }
    }

    function pause() {
        if(timer.running) {
            timer.stop();
        }
    }

    function reset() {
        if(timer.running) {
            timer.stop();
        }
        if(insomniac.running) {
            insomniac.stop();
        }
        seconds = minutes = 0;
    }

    function start() {
        if(!timer.running) {
            _lastTick = Math.round(Date.now()/1000);
            lastTimerMin = minutes;
            lastTimerSec = seconds;
            timer.start();
        }
    }

    function snooze() {
        timer.stop();
        _remaining = seconds + (minutes * 60);
        _lastTick = Math.round(Date.now()/1000);
        // Subtract 10 seconds for timer window
        insomniac.interval =_remaining - 10;
        insomniac.start();
    }

    function wakeUp() {
        if(insomniac.running) {
            insomniac.stop();
        }

        var now = Math.round(Date.now()/1000);
        var passed = now - _lastTick;
        _lastTick = now;

        if(passed >= _remaining) {
            console.warn('Time has passed!', passed - _remaining, 'seconds');
            reset();
            activate();
            alarm.play();
        } else {
            timer.start();
            _remaining = _remaining - passed;
            if(_remaining > 60) {
                minutes = Math.floor(_remaining/60);
                seconds = Math.round(_remaining - (minutes*60));
            } else {
                minutes = 0;
                seconds = _remaining;
            }
        }
    }
}


