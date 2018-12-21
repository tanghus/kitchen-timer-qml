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
        model: timersModel;
        anchors.leftMargin: Theme.paddingLarge;
        anchors.rightMargin: Theme.paddingLarge;
        width: parent.width;
        y: header.height + Theme.paddingMedium;
        contentHeight: timersModel.count * Theme.itemSizeSmall;
        height: parent.height - (header.height + Theme.paddingMedium + addButton.height);
        header: SectionHeader {
            text: qsTr("The max value is '59:59'")
        }

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
                TextField {
                    id: minutes;
                    anchors.left: name.right;
                    placeholderText: qsTr('Minutes');
                    text: model.minutes >= 10 ? model.minutes : '0' + String(model.minutes);
                    horizontalAlignment: TextInput.AlignRight;
                    inputMethodHints: Qt.ImhFormattedNumbersOnly;
                    errorHighlight: !validateTime(index, text, "minutes")
                    EnterKey.enabled: validateTime(index, text, "minutes")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: seconds.focus = true
                    validator: IntValidator {
                        bottom: 0;
                        top: 60;
                    }
                    onTextChanged:  {
                        // If nothing entered do continue
                        if(text.length === 0)
                            return
                        var tmp = parseInt(text)
                        if(tmp !== NaN
                                && tmp >= 0
                                && tmp < 60
                            ) {
                            timersModel.setProperty(index, 'minutes', tmp);
                        } else {
                            text = timersModel.get(index).minutes
                        }
                    }
                    onFocusChanged: {
                        if(validateTime(index, text, "minutes")) {
                            timersModel.setProperty(index, "minutes", formatTime(text));
                        } else {
                            // Grab the value from the model
                            text = formatTime(timersModel.get(index).minutes)
                        }
                    }
                }
                Label {
                    id: separator;
                    anchors.left: minutes.right;
                    text: ':';
                    color: minutes.color;//Theme.secondaryHighlightColor;
                }

                TextField {
                    id: seconds;
                    anchors.left: separator.right;
                    placeholderText: qsTr('Seconds');
                    text: model.seconds >= 10 ? model.seconds : '0' + String(model.seconds);
                    horizontalAlignment: TextInput.AlignLeft;
                    inputMethodHints: Qt.ImhFormattedNumbersOnly;
                    errorHighlight: !validateTime(index, text, "seconds")
                    EnterKey.enabled: validateTime(index, text, "seconds")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: minutes.focus = true
                    validator: IntValidator {
                        bottom: 0;
                        top: 60;
                    }
                    onTextChanged:  {
                        // If nothing entered do continue
                        if(text.length === 0)
                            return
                        var tmp = parseInt(text)
                        if(tmp !== NaN 
                                && tmp >= 0 
                                && tmp < 60 
                            ) {
                            timersModel.setProperty(index, "seconds", tmp);
                        } else {
                            text = timersModel.get(index).seconds
                        }
                    }
                    onFocusChanged: {
                        if(validateTime(index, text, "seconds")) {
                            timersModel.setProperty(index, "seconds", formatTime(text));
                        } else {
                            // Grab the value from the model
                            text = formatTime(timersModel.get(index).seconds)
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
        ViewPlaceholder {
            enabled: timersList.count === 0;
            text: 'No timers defined. Pull down to add one.';
        }
    }
    IconButton {
        id: addButton;
        anchors.top: timersList.bottom;
        anchors.right: timersList.right;
        anchors.rightMargin: Theme.paddingMedium;
        icon.source: 'image://theme/icon-m-add';
        visible: timersModel.count < 8;
        onClicked: {
            timersModel.append(
                        {
                            name: 'New timer',
                            minutes: '00',
                            seconds: '00'
                        }
                        );
            timersList.positionViewAtEnd();
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
        newText = t < 60 ? t : 59
        // Format time '0' => '00', '9' => '09' etc.
        newText = t >= 10 ? t : '0' + String(t);
        return newText
    }

    /*
     * idx: int: Model index
     * timeText: String: The actual text in the TextField
     * minsec: String: Whether it's a "minutes" or "seconds" field
     */
    function validateTime(idx, timeText, minsec) {
        var minutes, seconds

        // If editing minutes use the seconds value from the model
        if(minsec === "minutes") {
            minutes = parseInt(timeText)
            seconds = parseInt(timersModel.get(idx).seconds)
        }

        // If editing seconds use the minutes value from the model
        if(minsec === "seconds") {
            minutes = parseInt(timersModel.get(idx).minutes)
            seconds = parseInt(timeText)
        }

        // The total time cannot be longer than 1 hour - 1 second
        if(seconds + (minutes*60) < 3600) {
            return true
        } else {
            return false
        }
    }
}

