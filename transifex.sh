#!/usr/bin/env bash

echo "[https://www.transifex.com]\nhostname = https://www.transifex.com\npassword = $TRANSIFEX\ntoken = \nusername = tanghus" > ~/.transifexrc
cat ~/.transifexrc
cd translations

git clone http://code.transifex.com/transifex-client
cd transifex-client
python setup.py install --user

~/.local/bin/tx pull --all
