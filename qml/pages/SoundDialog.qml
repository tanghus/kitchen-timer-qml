/*
  Copyright (C) 2015 Thomas Tanghus
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

Dialog {
    id: soundDialog;
    allowedOrientations: Orientation.Portrait | Orientation.Landscape;

    //canAccept: false;

    property bool vibrate: false;
    property bool sound: true;

    DialogHeader {
        id: header;
        dialog: soundDialog;
        title: qsTr('Sound');
    }

    SilicaFlickable {
        y: header.height + Theme.paddingMedium;
        height: parent.height - (header.height + Theme.paddingMedium);
        anchors.leftMargin: Theme.paddingLarge;
        anchors.rightMargin: Theme.paddingLarge;

        Column {
            id: column;
            anchors.fill: parent;

            width: soundDialog.width;
            spacing: Theme.paddingLarge;

            TextSwitch {
                id: noSound;
                anchors.top: parent.top;
                checked: !sound;
                leftMargin: Theme.paddingMedium;
                text: qsTr('Disable sound');
                onCheckedChanged: {
                    console.log('NoSound', checked)
                    sound = !checked;
                }
                onClicked: {
                    console.log('NoSound tapped', automaticCheck)
                }
            }

            TextSwitch {
                id: doVibrate;
                anchors.top: noSound.bottom;
                checked: vibrate;
                leftMargin: Theme.paddingMedium;
                text: qsTr('Vibrate');
                description: 'Since <code>QtFeedback</code> is not yet allowed, this does nothing.';
                onCheckedChanged: {
                    console.log('Vibrate', checked)
                    vibrate = checked;
                }
            }

            BackgroundItem {
                //enabled: sound;
                anchors.top: doVibrate.bottom;
                width: parent.width;
                Label {
                    textFormat: Text.StyledText;
                    text: '<img src="image://theme/icon-l-music" />&nbsp;' + qsTr('Select music file');
                }
                onClicked: {
                    console.log('Select file', checked)
                    pageStack.push(Qt.resolvedUrl('SoundSelectDialog.qml'));
                }
            }
        }
    }
}
