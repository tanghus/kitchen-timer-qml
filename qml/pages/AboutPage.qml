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

Page {
    allowedOrientations: Orientation.Portrait | Orientation.Landscape;

    SilicaFlickable {
        anchors.fill: parent;
    Label {
        anchors.centerIn: parent;
        width: parent.width;
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        horizontalAlignment: Text.AlignHCenter;
        textFormat: Text.RichText;
        text: "<style>a:link { color: " + Theme.highlightColor + "; }</style>" +
              "Kitchen Timer v." + Qt.application.version + "<br/>" +
              qsTr('Simple Kitchen Timer app') + '<br/>' +
              //: Naming the author
              qsTr('by %1', 'As in made by %1').arg('Thomas Tanghus') + '<br/><br/>' +
              //: Link to Github project page
              qsTr('See more at %1.', 'Link URL').arg(' <a href="https://github.com/tanghus/kitchen-timer-qml">%1</a>').arg(qsTr('the project page', 'Link text')) + '<br/><br/>' +
              //: Link to the issue tracker
              qsTr('Issues and feature requests at the %1', 'Link URL').arg('<a href="https://github.com/tanghus/kitchen-timer-qml/issues">%1</a>.').arg(qsTr('issue tracker', 'Link text')) + '<br/><br/>' +
              //: %1: Author nick, %2:Link to Web IRC
              qsTr('Ask "%1" at the %2 channel on Freenode IRC for support', 'Link with text').arg('tanghus').arg('<a href="http://webchat.freenode.net/?channels=sailfishos">#sailfishos</a>') + '<br/><br/>' +
              qsTr('The awesome icon is made by %1').arg('Alain M') + ' <a href="https://twitter.com/capricotwi04">@capricotwi04</a> <a href="mailto:alain_m@gmx.ch">alain_m@gmx.ch</a>';

        onLinkActivated: {
            Qt.openUrlExternally(link)
        }
    }
    }
}
