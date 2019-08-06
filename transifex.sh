#!/usr/bin/env bash

git clone http://code.transifex.com/transifex-client > /dev/null || exit 1
cd transifex-client || exit 1
python setup.py install --user > /dev/null
cd ..

echo "[https://www.transifex.com]" > ~/.transifexrc
echo "hostname = https://www.transifex.com" >> ~/.transifexrc
echo "password = 1/2086ec1d18862fe6f7e630064ae68590372f5c3d" >> ~/.transifexrc
echo "token = 1/2086ec1d18862fe6f7e630064ae68590372f5c3d" >> ~/.transifexrc
echo "username = tanghus" >> ~/.transifexrc
echo "lang_map = el: el_GR, de: de_DE, en: en_GB, da: da_DK, sv: sv_SE, ru: ru_RU" >> ~/.transifexrc
#echo """ >> ~/.transifexrc
echo "[kitchen-timer-qml.translations]" >> ~/.transifexrc
echo "hostname = https://www.transifex.com" >> ~/.transifexrc
echo "file_filter = <lang>.ts" >> ~/.transifexrc
echo "source_file = en_GB.ts" >> ~/.transifexrc
echo "source_lang = en_GB" >> ~/.transifexrc
echo "type = QT" >> ~/.transifexrc

cat  ~/.transifexrc

cd translations

~/.local/bin/tx push -s || exit 1
#~/.local/bin/tx pull -af || exit 1

rm  ~/.transifexrc

