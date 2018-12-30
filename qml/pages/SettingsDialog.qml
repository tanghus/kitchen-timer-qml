/*
  Copyright (C) 2015-2019 Thomas Tanghus
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
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.Media 1.0 
//import "../components"

Dialog {
    id: settingsDialog;
    allowedOrientations: Orientation.All //Portrait | Orientation.Landscape;

    //property bool vibrate: false;
    property string tmpSelectedSound: selectedSound;
    property bool tmpUseDefaultSound: useDefaultSound;
    property bool tmpLoopSound: loopSound;
    property bool tmpLoadLast: loadLast;
    property int tmpTimersAlignment: timersAlignment
    property alias timersAlignmentText: alignmentCombo.value

    //canAccept: useDefaultSound || tmpSelectedSound !== selectedSound;

    SilicaFlickable {
        height: isPortrait ? Screen.height : Screen.width
        anchors.fill: parent
        quickScroll: true
        VerticalScrollDecorator {} // { flickable: parent }

        DialogHeader {
            id: header;
            dialog: settingsDialog;
            title: qsTr("Settings");
        }

        Column {
            id: column;

            y: header.height + Theme.paddingMedium;
            //height: parent.height - (header.height + Theme.paddingMedium);
            anchors.leftMargin: Theme.paddingLarge;
            anchors.rightMargin: Theme.paddingLarge;
            width: settingsDialog.width;
            spacing: Theme.horizontalPageMargin;

            TextSwitch {
                id: doLoadLast;
                checked: loadLast;
                x: Theme.paddingLarge;
                text: qsTr("Load last timer");
                description: qsTr("Reload the last timer when starting the app");
                onCheckedChanged: {
                    //console.log("LoadLast", checked)
                    tmpLoadLast = checked;
                }
            }

            ComboBox {
                id: alignmentCombo
                label: qsTr("Timers menu alignment")
                description: qsTr("Select to which side of the screen the predefined timers menu should be placed")
                onCurrentIndexChanged: {
                    var alignmentObject = alignmentModel.get(currentIndex)
                    value = alignmentObject.align
                    tmpTimersAlignment = alignmentObject.value
                    timersAlignmentText = alignmentObject.align
                }

                Component.onCompleted: {
                    currentIndex = getIndex(timersAlignment)
                    value = alignmentModel.get(currentIndex).align
                }

                menu: ContextMenu {
                    Repeater {
                        model: alignmentModel
                        delegate: MenuItem {
                            Label {
                                text: model.align
                            }
                        }
                    }
                    ListModel {
                        id: alignmentModel
                        ListElement { align: qsTr("Left"); value: Dock.Left }
                        ListElement { align: qsTr("Right"); value: Dock.Right }
                    }
                }

                function getIndex(value) {
                    for(var i = 0; i < alignmentModel.count; i++) {
                        if(value === alignmentModel.get(i).value) {
                            console.log("Got it:", value)
                            return i
                        }
                    }
                }
            }

            Label {
                text: qsTr("Alarm sound")
                x: Theme.paddingLarge;
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
            }

            TextSwitch {
                id: doLoop;
                checked: loopSound;
                x: Theme.paddingLarge;
                text: qsTr("Loop alarm sound");
                description: qsTr("Repeat alarm sound until you stop it");
                onCheckedChanged: {
                    console.log("Loop", checked)
                    tmpLoopSound = checked;
                }
            }

            TextSwitch {
                id: soundSelector;
                checked: useDefaultSound;
                x: Theme.paddingLarge;
                text: qsTr("Default sound");
                description: qsTr("Use the alarm sound provided by the app");
                onCheckedChanged: {
                    console.log("useDefaultSound", checked);
                    tmpUseDefaultSound = checked;
                    if(checked) {
                        sound.source = builtinSound;
                        //tmpSelectedSound = builtinSound;
                        console.log("Using builtinSound", builtinSound);
                    }
                }
            }

            /*TextSwitch {
            id: doVibrate;
            checked: vibrate;
            x: Theme.paddingLarge;
            text: qsTr("Vibrate");
            description: "Since <code>QtFeedback</code> is not yet allowed, this does nothing.";
            onCheckedChanged: {
                console.log("Vibrate", checked)
                vibrate = checked;
            }
            }*/

            ValueButton {
                enabled: !tmpUseDefaultSound;
                label: qsTr("Select music file")
                value: baseName(tmpSelectedSound)
                onClicked: {
                    pageStack.push(musicPickerPage);
                }
            }
            Row {
                id: notDefault
                spacing: Theme.paddingMedium;
                x: Theme.paddingLarge;
                Label {
                    x: Theme.paddingLarge;
                    text: qsTr("Test alarm sound")
                }
                IconButton {
                    id: playIcon;
                    icon.source: sound.playbackState === Audio.PlayingState
                                 ? "image://theme/icon-m-pause"
                                 : "image://theme/icon-m-play";
                    
                    onClicked: {
                        sound.source = tmpUseDefaultSound ? builtinSound : tmpSelectedSound;
                        if(sound.playbackState === Audio.PlayingState) {
                            sound.stop();
                        } else {
                            sound.play();
                        }
                    }
                }
            }
        }
        contentHeight: column.height + notDefault.height + header.height
    }

    onAccepted: {
        timersAlignment = tmpTimersAlignment
        loopSound = tmpLoopSound
        loadLast = tmpLoadLast
        useDefaultSound = tmpUseDefaultSound
        selectedSound = tmpSelectedSound

        // The settings should be saved in ApplicationWindow.onDestruction,
        // but that isn't called when closing an app
        saveSettings()
    }

    Component {
        id: musicPickerPage
        MusicPickerPage {
            onSelectedContentPropertiesChanged: {
                tmpSelectedSound = selectedContentProperties.filePath
                sound.source = tmpSelectedSound
            }
        }
    }

    Audio {
        id: sound
        loops: tmpLoopSound ? Audio.Infinite : 1
        source: selectedSound
        audioRole: Audio.AlarmRole
        onError: {
            console.log("Audio error:", errorString, selectedSound)
        }
    }

    function baseName(path) {
        return path.split(/[\\/]/).pop()
    }
}
