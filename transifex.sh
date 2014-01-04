#!/usr/bin/env bash

cd translations

git clone http://code.transifex.com/transifex-client
cd transifex-client
python setup.py install --user

echo "[https://www.transifex.com]" > ~/.transifexrc
echo "hostname = https://www.transifex.com" >> ~/.transifexrc
echo "password = $TRANSIFEX" >> ~/.transifexrc
echo "token = " >> ~/.transifexrc
echo "username = tanghus" >> ~/.transifexrc
cat ~/.transifexrc

~/.local/bin/tx pull --all

rm  ~/.transifexrc
