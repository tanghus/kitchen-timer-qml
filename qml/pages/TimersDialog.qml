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
import Sailfish.Silica 1.0


Dialog {
    id: timersDialog;

    DialogHeader {
        id: header;
    }
    SilicaListView {
        id: timersList;
        model: timersModel;
        anchors.leftMargin: Theme.paddingLarge;
        anchors.rightMargin: Theme.paddingLarge;
        width: parent.width;
        y: header.height + Theme.paddingMedium;
        height: timersModel.count * Theme.itemSizeSmall;
        //height: parent.height - (header.height + Theme.paddingMedium);

        delegate: BackgroundItem {
            id: delegate;
            height: Theme.itemSizeSmall;

            property bool changed: false;

            Item {
                TextField {
                    id: name;
                    placeholderText: 'Timer name';
                    text: model.name;
                    width: font.pixelSize * 8;
                    RegExpValidator { regExp: /(\w{1,10}\b)/g }
                    onTextChanged:  {
                        if(text.length > 0) {
                            timersModel.setProperty(index, 'text',  text);
                        }
                    }
                }
                TextField {
                    id: minutes;
                    anchors.left: name.right;
                    placeholderText: 'Minutes';
                    text: model.minutes >= 10 ? model.minutes : '0' + String(model.minutes);
                    width: font.pixelSize * 3;
                    horizontalAlignment: TextInput.AlignRight;
                    inputMethodHints: Qt.ImhFormattedNumbersOnly;
                    validator: IntValidator {
                        bottom: 0;
                        top: 60;
                    }
                    onTextChanged:  {
                        if(parseInt(text)) {
                            timersModel.setProperty(index, 'minutes', parseInt(text));
                        }
                    }
                }
                TextField {
                    id: seconds;
                    anchors.left: minutes.right;
                    placeholderText: 'Seconds';
                    text: model.seconds >= 10 ? model.seconds : '0' + String(model.seconds);
                    width: font.pixelSize * 3;
                    horizontalAlignment: TextInput.AlignRight;
                    inputMethodHints: Qt.ImhFormattedNumbersOnly;
                    validator: IntValidator {
                        bottom: 0;
                        top: 60;
                    }
                    onTextChanged:  {
                        if(parseInt(text)) {
                            timersModel.setProperty(index, 'seconds', parseInt(text));
                        }
                    }
                }
                IconButton {
                   anchors.left: seconds.right;
                   icon.source: 'image://theme/icon-m-delete';
                   onClicked: {
                       console.log("Delete!");
                       var idx = index;
                       remorse.execute(delegate, "Deleting", function() {
                           timersModel.remove(idx)
                       });
                   }
                   RemorseItem { id: remorse }
                }
            }
            //onClicked: console.log("Clicked:", model.timer, name.text)
        }
    }
    IconButton {
        anchors.top: timersList.bottom;
        anchors.right: timersList.right;
        icon.source: 'image://theme/icon-m-add';
        //anchors.horizontalCenter: timersList.horizontalCenter;
        visible: timersModel.count < 8;
        onClicked: {
            timersModel.append(
                        {
                            name: 'New timer',
                            minutes: 0,
                            seconds: 0
                        }
                        );
        }
    }

    onDone: {
        console.log('Done:', (result === DialogResult.Accepted));
        result === DialogResult.Accepted ? save() : reload();
    }
}





