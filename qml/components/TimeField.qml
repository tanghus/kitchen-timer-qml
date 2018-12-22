/****************************************************************************************
**
** Copyright (C) 2013-19 Thomas Tanghus
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
** Modified from Sailfish Silica TimePicker by Thomas Tanghus.
****************************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0

TextField {
    horizontalAlignment: TextInput.AlignRight;
    inputMethodHints: Qt.ImhFormattedNumbersOnly;
    EnterKey.iconSource: "image://theme/icon-m-enter-next"
    validator: IntValidator {
        bottom: 0;
        top: 60;
    }

    property string timeType: ""

    onTextChanged:  {
        // If nothing entered continue
        if(text.length === 0)
            return
        var tmp = parseInt(text)
        if(tmp !== NaN
                && tmp >= 0
                && tmp < 60
            ) {
            timersModel.setProperty(index, timeType, tmp);
        } else {
            text = String(timersModel.get(index)[timeType])
        }
    }
}
