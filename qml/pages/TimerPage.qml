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
    property date time: new Date(0, 0, 0, 0, minutes, seconds);
    property bool isRunning: false;
    property Item contextMenu;

    Component.onCompleted: {
        timeText = Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), 'mm:ss');
        console.log('Ready', Qt.resolvedUrl('../../sounds/harbour-kitchentimer.wav'));
    }

    onSecondsChanged: {
        showTime();
        if(seconds === 0 && minutes > 0) {
            seconds = 60;
            minutes -= 1;
        }
    }

    onMinutesChanged: {
        showTime();
    }

    function showTime() {
        timeText = Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), 'mm:ss');
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
                isRunning = false;
                alarm.play();
                // Sound the bell!
            }
            /*if(seconds % 60 === 0) {
                minutes -= 1;
            }*/
        }
    }

    SilicaFlickable {
        anchors.fill: parent;

        PullDownMenu {
            MenuItem {
                text: 'Default timers';
                onClicked: pageStack.push(Qt.resolvedUrl('TimersDialog.qml'))
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
                    hour: 0; minute: 0;
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
                            isRunning = false;
                        } else if(!isRunning && alarm.playing) {
                            alarm.stop();
                        } else if(seconds > 0 || minutes > 0) {
                            timer.start();
                            isRunning = true;
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

        Component {
            id: contextMenuComponent;
            ContextMenu {
                MenuItem {
                    visible: !isRunning && (minutes > 0 || seconds > 0);
                    text: 'Start';
                    onClicked: {
                        timer.start();
                        isRunning = true;
                    }
                }
                MenuItem {
                    visible: isRunning;
                    text: 'Pause';
                    onClicked: {
                        timer.stop();
                        isRunning = false;
                    }
                }
                MenuItem {
                    visible: (minutes > 0 || seconds > 0);
                    text: 'Reset';
                    onClicked: {
                        timer.stop();
                        isRunning = false;
                        seconds = minutes = 0;
                    }
                }
                MenuItem {
                    visible: alarm.playing;
                    text: 'Silence';
                    onClicked: {
                        alarm.stop();
                    }
                }
            }
        }
    }
}


