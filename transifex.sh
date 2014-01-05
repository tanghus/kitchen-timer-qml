#!/usr/bin/env bash

git clone http://code.transifex.com/transifex-client > /dev/null
cd transifex-client
python setup.py install --user > /dev/null

cat >> ~/.transifexrc <<EOF
hostname = https://www.transifex.com
password = $TRANSIFEX
token =
username = tanghus
EOF

#echo "[https://www.transifex.com]" > ~/.transifexrc
#echo "hostname = https://www.transifex.com" >> ~/.transifexrc
#echo "password = $TRANSIFEX" >> ~/.transifexrc
#echo "token = " >> ~/.transifexrc
#echo "username = tanghus" >> ~/.transifexrc

cd ../translations

~/.local/bin/tx push -s en_GB.ts
~/.local/bin/tx pull --all

rm  ~/.transifexrc
