/*
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
import QtMultimedia 5.0
import Sailfish.Silica 1.0


Page {
    id: timerPage;

    property alias seconds: timePicker.minute;
    property alias minutes: timePicker.hour;
    property alias isPlaying: alarm.playing;
    property alias isRunning: timer.running;
    property date time: new Date(0, 0, 0, 0, minutes, seconds);
    property Item contextMenu;

    Component.onCompleted: {
        timeText = Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), 'mm:ss');
        console.log('Ready', Qt.resolvedUrl('../../sounds/harbour-kitchentimer.wav'));
    }

    onIsRunningChanged: {
        setMenuModel();
    }

    onIsPlayingChanged: {
        setMenuModel();
    }

    onSecondsChanged: {
        showTime();
        if(seconds === 0 && minutes > 0) {
            seconds = 60;
            minutes -= 1;
        }
        setMenuModel();
    }

    onMinutesChanged: {
        showTime();
        setMenuModel();
    }

    function showTime() {
        timeText = Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), 'mm:ss');
        //console.log('Time:', timeText);
    }

    SoundEffect {
        id: alarm;
        loops: -2;
        source: Qt.resolvedUrl('../../sounds/harbour-kitchentimer.wav');
    }
    Timer {
        id: timer;
        interval: 1000;
        running: false; repeat: true;
        onTriggered: {
            seconds -= 1;
            time.setSeconds(seconds);
            if(minutes === 0 && seconds === 0) {
                timer.stop();
                alarm.play();
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent;

        PullDownMenu {
            MenuItem {
                text: 'Edit default timers';
                onClicked: pageStack.push(Qt.resolvedUrl('TimersDialog.qml'))
            }
            Repeater {
                 model: timersModel;
                 delegate: MenuItem {
                     text: model.name + ' '
                           + (model.minutes>= 10 ? model.minutes : '0' + String(model.minutes))
                           + ':'
                           + (model.seconds >= 10 ? model.seconds : '0' + String(model.seconds));
                     onClicked: {
                         setTime(model.minutes, model.seconds);
                         console.log('Selected timer', model.name);
                     }
                 }
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height;

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column;

            width: timerPage.width;
            spacing: Theme.paddingLarge;
            PageHeader {
                title: 'Kitchen Timer';
            }
            Item {
                width: column.width;
                TimePicker {
                    id: timePicker;
                    hour: minutes; minute: seconds;
                    showRangeIndicator: false;
                    //anchors.centerIn: column;
                    // Ugly, but, dang, I can't position it
                    x: (column.width - timePicker.width) / 2;
                    y: (Screen.height - timePicker.height) / 2;
                }
                BackgroundItem {
                    id: background;
                    anchors.centerIn: timePicker;
                    width: timerButton.width;
                    height: timerButton.height;

                    Label {
                        id: timerButton;
                        text: timeText;
                        color: background.highlighted ? Theme.highlightColor : Theme.primaryColor;
                        font.pixelSize: Theme.fontSizeExtraLarge;
                    }
                    onClicked: {
                        if(isRunning) {
                            timer.stop();
                        } else if(!isRunning && alarm.playing) {
                            alarm.stop();
                        } else if(seconds > 0 || minutes > 0) {
                            timer.start();
                        }
                    }
                    onPressAndHold: {
                        if((minutes === 0 && seconds === 0) & !alarm.playing && !isRunning) {
                            return;
                        }

                        if (!contextMenu) {
                            contextMenu = contextMenuComponent.createObject(timePicker)
                        }
                        contextMenu.show(timePicker)
                    }
                }
            }
        }

        ListModel {
            id: menuModel;
        }

        Component {
            id: contextMenuComponent;
            ContextMenu {
                Repeater {
                    id: menuRepeater;
                    model: menuModel;

                    delegate: MenuItem {
                        text: model.name;
                        onClicked: {
                            console.log('Action:', model.action);
                            runMenuAction(model.action);
                        }
                    }
                }
            }
        }
    }

    function setTime(mins, secs) {
        console.log('setTime:', mins, secs);
        timePicker.hour = mins;
        timePicker.minute = secs;
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
        seconds = minutes = 0;
    }

    function start() {
        if(!timer.running) {
            timer.start();
        }
    }

    function runMenuAction(action) {
        switch(action) {
            case 'start':
                start();
                break;
            case 'reset':
                reset();
                break;
            case 'mute':
                mute();
                break;
            case 'pause':
                pause();
                break;
        }
    }

    function setMenuModel() {
        menuModel.clear();
        var menuActions = {
            start: {name:'Start', action:'start'},
            pause: {name:'Pause', action:'pause'},
            reset: {name:'Reset', action:'reset'},
            mute: {name:'Mute', action:'mute'}
        }

        if(isRunning) {
            menuModel.append(menuActions.pause);
            menuModel.append(menuActions.reset);
        } else if(!isRunning && (minutes > 0 || seconds > 0)) {
            menuModel.append(menuActions.start);
            menuModel.append(menuActions.reset);
        } else if(minutes > 0 || seconds > 0) {
            menuModel.append(menuActions.reset);
        } else if(alarm.playing) {
            menuModel.append(menuActions.mute);
        }
    }

}


