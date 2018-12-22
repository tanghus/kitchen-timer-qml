/*
  Copyright (C) 2013-19 Thomas Tanghus
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
import "../components"

Page {
    id: timerPage;
    allowedOrientations: Orientation.All;

    property alias seconds: kitchenTimer.seconds;
    property alias minutes: kitchenTimer.minutes;
    property Item contextMenu;

    Component.onCompleted: {
        showTime();
    }

    onSecondsChanged: {
        showTime();
    }

    onMinutesChanged: {
        showTime();
    }

    SilicaFlickable {
        anchors.fill: parent;

        //onWidthChanged: {
        //    console.log(orientation === Orientation.Portrait ? "Portrait" : "Landscape")
        //}

        PullDownMenu {
            MenuItem {
                text: qsTr('About');
                onClicked: {
                    pageStack.push(Qt.resolvedUrl('AboutPage.qml'));
                }
            }
            MenuItem {
                text: qsTr('Edit default timers');
                onClicked: pageStack.push(Qt.resolvedUrl('TimersDialog.qml'));
            }
            MenuItem {
                text: qsTr('Settings');
                onClicked: pageStack.push(Qt.resolvedUrl('SettingsDialog.qml'));
            }
            MenuItem {
                text: qsTr('Last timer:')
                      + ' ' + (lastTimerMin >= 10 ? lastTimerMin : '0' + String(lastTimerMin)) + ':'
                      + (lastTimerSec >= 10 ? lastTimerSec : '0' + String(lastTimerSec));
                onClicked: {
                    setTime(lastTimerMin, lastTimerSec);
                }
                visible: lastTimerMin !== -1 && lastTimerSec !== -1;
            }
        }

        PushUpMenu {
            visible: timersModel.count > 0;
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

        Column {
            id: column;

            width: Screen.width - (Theme.paddingLarge * 2);
            spacing: Theme.paddingLarge;
            anchors.centerIn: parent;
            PageHeader {
                id: header;
                title: qsTr('Kitchen Timer');
                visible: timerPage.isPortrait ? true : false;
            }

            // Dummy element to create some top spacing when in Landscape and to center
            // KitchenTimer when in Portrait without messing with the Column. Not very elegant :-/
            Item {
                height: header.visible ?
                            (Screen.height/2)-(kitchenTimer.height/2)-header.height-(Theme.paddingLarge*2) :
                            Theme.paddingLarge;
                width: parent.width;
            }

            Item {
                width: column.width - (Theme.paddingLarge * 2);
                height : width;
                anchors.horizontalCenter: parent.horizontalCenter;
                KitchenTimer {
                    id: kitchenTimer;
                    anchors.centerIn: parent;
                }
                BackgroundItem {
                    id: timerButton;

                    property alias text: timerButtonLabel.text
                    anchors.centerIn: kitchenTimer;
                    width: timerButtonLabel.width + (Theme.paddingLarge*2)
                    height: timerButtonLabel.height

                    Rectangle {
                        anchors {
                            centerIn: parent
                            topMargin: (timerButton.height-Theme.itemSizeExtraSmall)/2
                            bottomMargin: anchors.topMargin
                        }
                        radius: Theme.paddingSmall
                        width: timerButtonLabel.width + (Theme.paddingLarge*2)
                        height: timerButtonLabel.height

                        color: timerButton._showPress ? Theme.rgba(timerButtonLabel.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                                          : Theme.rgba(timerButtonLabel.color, 0.2)

                        opacity: timerButton.enabled ? 1.0 : 0.4

                        Label {
                            id: timerButtonLabel
                            text: timeText;
                            anchors.centerIn: parent
                            color: timerButton.highlighted ? Theme.highlightColor : Theme.primaryColor
                            padding: Theme.paddingLarge
                            font {
                                pixelSize: Theme.fontSizeExtraLarge
                                bold: true
                            }
                        }
                    }

                    onPressedChanged: {
                        if (pressed) {
                            pressTimer.start()
                        }
                    }
                    onCanceled: {
                        timerButton.DragFilter.end()
                        pressTimer.stop()
                    }

                    onClicked: {
                        if(isRunning) {
                            pause();
                        } else if(!isRunning && isPlaying) {
                            mute();
                        } else if(seconds > 0 || minutes > 0) {
                            start();
                        }
                    }
                    onPressAndHold: {
                        setMenuModel();
                        if((minutes === 0 && seconds === 0) & !isPlaying && !isRunning) {
                            return;
                        }

                        if (!contextMenu) {
                            contextMenu = contextMenuComponent.createObject(kitchenTimer)
                        }
                        contextMenu.open(kitchenTimer)
                    }
                }
            }
        }

        ListModel {
            id: menuModel;
        }

        Timer {
            id: pressTimer
            interval: Theme.minimumPressHighlightTime
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
                            //console.log('Action:', model.action);
                            runMenuAction(model.action);
                        }
                    }
                }
            }
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
            start: {name:qsTr('Start'), action:'start'},
            pause: {name:qsTr('Pause'), action:'pause'},
            reset: {name:qsTr('Reset'), action:'reset'},
            mute: {name:qsTr('Mute'), action:'mute'}
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


