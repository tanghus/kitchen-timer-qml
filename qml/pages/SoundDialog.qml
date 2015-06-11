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

    //property bool vibrate: false;
    property string tmpSelectedSound: selectedSound;
    property bool tmpUseDefaultSound: useDefaultSound;
    property bool tmpLoopSound: loopSound;

    //canAccept: useDefaultSound || tmpSelectedSound !== selectedSound;

    DialogHeader {
        id: header;
        dialog: soundDialog;
        title: qsTr('Alarm sound');
    }

    Column {
        id: column;

        y: header.height + Theme.paddingMedium;
        height: parent.height - (header.height + Theme.paddingMedium);
        anchors.leftMargin: Theme.paddingLarge;
        anchors.rightMargin: Theme.paddingLarge;
        width: soundDialog.width;
        spacing: Theme.horizontalPageMargin;

        TextSwitch {
            id: doLoop;
            checked: loopSound;
            x: Theme.paddingLarge;
            text: qsTr('Loop alarm sound');
            description: qsTr('Repeat alarm sound until you stop it');
            onCheckedChanged: {
                console.log('Loop', checked)
                tmpLoopSound = checked;
            }
        }

        TextSwitch {
            id: soundSelector;
            checked: useDefaultSound;
            x: Theme.paddingLarge;
            text: qsTr('Default sound');
            onCheckedChanged: {
                console.log('useDefaultSound', tmpUseDefaultSound);
                tmpUseDefaultSound = checked;
                if(checked) {
                    tmpSelectedSound = builtinSound;
                }
            }
        }

        /*TextSwitch {
            id: doVibrate;
            checked: vibrate;
            x: Theme.paddingLarge;
            text: qsTr('Vibrate');
            description: 'Since <code>QtFeedback</code> is not yet allowed, this does nothing.';
            onCheckedChanged: {
                console.log('Vibrate', checked)
                vibrate = checked;
            }
        }*/

        BackgroundItem {
            enabled: !tmpUseDefaultSound;
            width: parent.width;
            Column {
                spacing: Theme.paddingSmall;
                x: Theme.paddingLarge;
                Row {
                    spacing: Theme.paddingMedium;
                    Image {
                        source: 'image://theme/icon-l-music';
                        width: Theme.fontSizeLarge;
                        height: Theme.fontSizeLarge;
                    }

                    Label {
                        id: selectedSoundLabel;
                        color: tmpUseDefaultSound ? Theme.secondaryColor : Theme.highlightColor;
                        textFormat: Text.StyledText;
                        text: baseName(tmpSelectedSound);
                    }
                }
                Label {
                    x: Theme.fontSizeLarge + Theme.paddingMedium;
                    color: tmpUseDefaultSound ? Theme.secondaryColor : Theme.primaryColor;
                    text: qsTr('Select music file');
                    font.pixelSize: Theme.fontSizeExtraSmall;
                }
            }

            onClicked: {
                //console.log('Select file', checked)
                var filePicker = pageStack.push(Qt.resolvedUrl('SoundSelectDialog.qml'));
                filePicker.accepted.connect(function() {
                    tmpSelectedSound = filePicker.selectedSound;
                });
            }
        }
    }
    onAccepted: {
        loopSound = tmpLoopSound;
        settings.setValue('loopSound', loopSound);

        useDefaultSound = tmpUseDefaultSound;
        settings.setValue('useDefaultSound', useDefaultSound);

        if(!useDefaultSound) {
            selectedSound = tmpSelectedSound;
            settings.setValue('selectedSound', selectedSound);
        }

    }

    function baseName(str) {
       var base = new String(str).substring(str.lastIndexOf('/') + 1);
        if(base.lastIndexOf(".") != -1)
            base = base.substring(0, base.lastIndexOf("."));
       return base;
    }

}

