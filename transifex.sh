#!/usr/bin/env bash

git clone http://code.transifex.com/transifex-client > /dev/null || exit 1
cd transifex-client || exit 1
python setup.py install --user > /dev/null

echo "[https://www.transifex.com]" > ~/.transifexrc
echo "hostname = https://www.transifex.com" >> ~/.transifexrc
echo "password = $TRANSIFEX" >> ~/.transifexrc
echo "token = " >> ~/.transifexrc
echo "username = tanghus" >> ~/.transifexrc
echo "lang_map = el: el_GR, de: de_DE, en: en_GB, da: da_DK, sv: sv_SE, ru: ru_RU" >> ~/.transifexrc
#echo """ >> ~/.transifexrc
echo "[kitchen-timer-qml.translations]" >> ~/.transifexrc
echo "file_filter = <lang>.ts" >> ~/.transifexrc
echo "source_file = en_GB.ts" >> ~/.transifexrc
echo "source_lang = en_GB" >> ~/.transifexrc
echo "type = QT" >> ~/.transifexrc

#cat  ~/.transifexrc

cd ../translations

~/.local/bin/tx push -s en_GB.ts || exit 1
#~/.local/bin/tx pull -af || exit 1

rm  ~/.transifexrc

