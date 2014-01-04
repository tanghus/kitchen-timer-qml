#!/usr/bin/env bash

echo "[https://www.transifex.com]\nhostname = https://www.transifex.com\npassword = $TRANSIFEX\ntoken = \nusername = tanghus" > ~/.transifexrc

cd translations

pip install transifex-client
tx pull --all
