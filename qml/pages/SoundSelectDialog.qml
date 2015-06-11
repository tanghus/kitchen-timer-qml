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
import harbour.kitchentimer.folderlistmodel 1.0

Dialog {
    id: soundsDialog;
    allowedOrientations: Orientation.Portrait | Orientation.Landscape;

    canAccept: false;

    property string selectedSound: '';

    DialogHeader {
        id: header;
        dialog: soundsDialog;
        acceptText: qsTr('Select');
        //title: qsTr('Select sound file');
    }

    Audio {
        id: sound;
    }

    SilicaListView {
        id: soundsList;
        quickScroll: true;
        //x: Theme.paddingLarge;
        currentIndex: -1;

        PullDownMenu {
            visible: soundsModel.path !== soundsModel.homePath();
            y: header.height;
            MenuItem {
                text: qsTr('Up');
                onClicked: {
                    soundsDialog.canAccept = false;
                    soundsModel.path = soundsModel.parentPath;
                }
            }
        }

        FolderListModel {
            id: soundsModel;
            path: homePath();
            nameFilters: ["*.mp3", "*.wav", "*.flac"];
            showDirectories: true;
            filterMode: FolderListModel.Inclusive;
        }

        model: soundsModel;
        //anchors.fill: parent;
        //anchors.topMargin: header.height;
        anchors.leftMargin: Theme.paddingLarge;
        anchors.rightMargin: Theme.paddingLarge;
        width: parent.width;
        y: header.height + Theme.paddingMedium;
        contentHeight: soundsModel.count * Theme.itemSizeSmall;
        height: parent.height - (header.height + Theme.paddingMedium);

        delegate: ListItem {
            id: soundItem;
            contentHeight: Theme.itemSizeSmall;
            highlighted: model.index === soundsList.currentIndex && !model.isDir;
            onClicked: {
                console.log('Tapped: ', soundsList.currentIndex, model.index, model.filePath, model.fileName);
                if(model.isDir) {
                    soundsModel.path = model.filePath;
                    soundsDialog.canAccept = false;
                    if(sound.playbackState === Audio.PlayingState) {
                        sound.stop();
                    }
                } else {
                    selectedSound = model.filePath;
                    soundsList.currentIndex = model.index;
                    soundsDialog.canAccept = highlighted;

                    console.log('highlighted:', highlighted);
                    console.log('sound playing:', sound.playbackState === Audio.PlayingState);
                    if(highlighted) {
                        if(sound.playbackState === Audio.PlayingState) {
                            sound.stop();
                        } else {
                            sound.source = model.filePath;
                            sound.play();
                        }

                        console.log('sound playing:', sound.playbackState === Audio.PlayingState);
                    } else {
                        soundsList.currentIndex = -1;
                        if(sound.playing) {
                            sound.stop();
                        }
                    }
                }
            }

            onFocusChanged: {
                /*console.log('Focus change', model.index, soundsList.currentIndex, soundsList.lastItem);
                if(soundsList.lastItem > -1 && model.index !== soundsList.lastItem) {
                    console.log('deselecting', model.index, soundsList.lastItem, highlighted, soundsList.highlightFollowsCurrentItem);
                    highlighted = false;
                }*/
            }

            onCanceled: {
                console.log('Cancelled', model.index);
            }

            Image {
                id: icon;
                x: Theme.paddingLarge;
                width: Theme.fontSizeLarge;
                height: Theme.fontSizeLarge;
                source: model.isDir ? 'image://theme/icon-m-folder' : 'image://theme/icon-l-music';
            }
            Label {
                id: name;
                x: (Theme.paddingLarge * 2) + Theme.fontSizeLarge;
                //anchors.left: icon.right;
                truncationMode: TruncationMode.Fade;
                text: model.fileName;
                width: parent.width;
                color: model.index === soundsList.currentIndex ? Theme.highlightColor : Theme.secondaryColor;
                //color: highlighted ? Theme.highlightColor : Theme.secondaryColor;
            }
        }
        VerticalScrollDecorator {
            flickable: soundsList;
        }
        ViewPlaceholder {
            enabled: soundsList.count === 0;
            text: qsTr('No sound files here.');
        }
    }

    function deSelect(idx) {
        console.log('deSelect', idx);
        /*for (var i = 0; i < soundsList.contentItem.children.length; ++i) {
            console.log('Child type:', soundsList.contentItem.children[i].highlighted);
        }
        if(soundsList.contentItem.children[idx].highligted) {
            soundsList.contentItem.children[idx].highligted = false;
        }*/
    }

    /*onAccepted: {
        tmpSelectedSound = _selectedSound;
    }*/
}
