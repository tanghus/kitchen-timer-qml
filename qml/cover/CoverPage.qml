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

CoverBackground {

    signal pause();
    signal mute();
    signal start();
    signal reset();

    Column {
        anchors.fill: parent;
        anchors.leftMargin: Theme.paddingLarge;
        anchors.rightMargin: Theme.paddingLarge;
        Label {
            text: 'Timer';
            truncationMode: TruncationMode.Fade;
            horizontalAlignment: Text.AlignHCenter;
            width: parent.width;
            font.pixelSize: Theme.fontSizeExtraLarge;
        }
        Label {
            text: timeText;
            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignBottom;
            width: parent.width;
            font.pixelSize: Theme.fontSizeHuge;
        }
    }

    CoverActionList {
        id: ticking;
        enabled: isRunning;

        CoverAction {
            iconSource: "image://theme/icon-cover-cancel";
            onTriggered: reset();
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
            onTriggered: pause();
        }
    }

    CoverActionList {
        id: paused;
        enabled: !isRunning && (minutes > 0 || seconds > 0);

        CoverAction {
            iconSource: "image://theme/icon-cover-play";
            onTriggered: start();
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: reset();
        }
    }

    CoverActionList {
        id: alarm;
        enabled: isPlaying;

        CoverAction {
            iconSource: "image://theme/icon-cover-mute";
            onTriggered: mute();
        }
    }

}


