#!/usr/bin/env bash

git clone http://code.transifex.com/transifex-client
cd transifex-client
python setup.py install --user

echo "[https://www.transifex.com]" > ~/.transifexrc
echo "hostname = https://www.transifex.com" >> ~/.transifexrc
echo "password = $TRANSIFEX" >> ~/.transifexrc
echo "token = " >> ~/.transifexrc
echo "username = tanghus" >> ~/.transifexrc

cd ../translations

~/.local/bin/tx push -r en_GB.ts
~/.local/bin/tx pull --all

rm  ~/.transifexrc

`git diff` && git commit -a -m "Updated from Transifex" && git push origin master
