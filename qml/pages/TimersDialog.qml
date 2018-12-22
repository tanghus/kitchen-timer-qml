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

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import "../components"

Dialog {
    id: timersDialog;
    allowedOrientations: Orientation.Portrait | Orientation.Landscape;

    DialogHeader {
        id: header;
        dialog: timersDialog
        title: qsTr("Timers")
    }

    SilicaListView {
        id: timersList;
        header: SectionHeader {
            text: qsTr("Max value is '59:59'")
        }

        footer: SectionHeader {
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Pull up to add a timer")
        }

        PushUpMenu {
            id: menu
            MenuItem {
                text: qsTr('Add timer');
                onClicked: {
                    console.log("Adding timer")
                    timersModel.append({
                                    name: 'New timer',
                                    minutes: 0,
                                    seconds: 0
                                });
                    timersList.positionViewAtEnd();
                }
            }
        }

        model: timersModel;
        anchors {
            horizontalCenter: header.horizontalCenter
            leftMargin: Theme.paddingLarge;
            rightMargin: Theme.paddingLarge;
        }
        width: Screen.width;
        y: header.height + Theme.paddingSmall;
        contentHeight: timersModel.count * Theme.itemSizeSmall;
        height: parent.height - (header.height + Theme.paddingMedium);

        delegate: ListItem {
            id: timerItem;
            contentHeight: Theme.itemSizeSmall;
            ListView.onRemove: animateRemoval(timerItem)

            function remove() {
                remorseAction(qsTr('Deleting'), function() {
                    timersList.model.remove(index);
                });
            }

            Item {
                TextField {
                    id: name;
                    placeholderText: qsTr('Timer name');
                    text: model.name;
                    width: font.pixelSize * 8;
                    RegExpValidator { regExp: /(\w{1,10}\b)/g }
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: minutes.focus = true
                    onFocusChanged:  {
                        if(text.length > 0) {
                            timersModel.setProperty(index, 'name',  text);
                        }
                    }
                }

                TimeField {
                    id: "minutes"
                    anchors.left: name.right;
                    timeType: "minutes"
                    text: model.minutes >= 10 ? model.minutes : '0' + String(model.minutes);
                    placeholderText: qsTr('Minutes');
                    errorHighlight: !validateTime(index, text, "minutes")
                    EnterKey.enabled: validateTime(index, text, "minutes")
                    EnterKey.onClicked: seconds.focus = true
                    onFocusChanged: {
                        if(validateTime(index, text, timeType)) {
                            timersModel.setProperty(index, timeType, formatTime(text));
                        } else {
                            // Grab the value from the model
                            text = formatTime(timersModel.get(index)[timeType])
                        }
                    }
                }

                Label {
                    id: separator;
                    anchors.left: minutes.right;
                    text: ':';
                    color: minutes.color;
                }

                TimeField {
                    id: "seconds"
                    anchors.left: separator.right;
                    timeType: "seconds"
                    text: model.seconds >= 10 ? String(model.seconds) : '0' + String(model.seconds);
                    placeholderText: qsTr('Seconds');
                    errorHighlight: !validateTime(index, text, timeType)
                    EnterKey.enabled: validateTime(index, text, timeType)
                    EnterKey.onClicked: seconds.focus = true
                    onFocusChanged: {
                        if(validateTime(index, text, timeType)) {
                            timersModel.setProperty(index, timeType, formatTime(text));
                        } else {
                            // Grab the value from the model
                            text = formatTime(timersModel.get(index)[timeType])
                        }
                    }
                }

                IconButton {
                   anchors.left: seconds.right;
                   icon.source: 'image://theme/icon-m-delete';
                   onClicked: remove();
                }
            }
        }
        VerticalScrollDecorator {
            flickable: timersList;
        }
    }

    onDone: {
        result === DialogResult.Accepted ? save() : reload();
    }

    function formatTime(text) {
        var t = parseInt(text), newText
        if(t === NaN) {
            return "00"
        }

        // I'd like to do this in a READABLE one-liner
        // Make sure that time is not more than 59 mins. and 59 secs
        newText = t < 60 ? String(t) : "59"
        // Format time '0' => '00', '9' => '09' etc.
        newText = t >= 10 ? String(t) : "0" + String(t);
        return newText
    }

    /*
     * idx: int: Model index
     * timeText: String: The actual text in the TextField
     * minsec: String: Whether it's a "minutes" or "seconds" field
     */
    function validateTime(idx, timeText, minsec) {
        var minutes, seconds, item = timersModel.get(idx)

        // If editing minutes use the seconds value from the model
        if(minsec === "minutes" && item) {
            minutes = parseInt(timeText)
            seconds = parseInt(item.seconds)
        }

        // If editing seconds use the minutes value from the model
        if(minsec === "seconds" && item) {
            minutes = parseInt(item.minutes)
            seconds = parseInt(timeText)
        }

        // The total time must be > 0 and less than an hour
        var total = seconds + (minutes*60)
        if(total > 0 && total < 3600) {
            return true
        } else {
            return false
        }
    }
}

