#!/usr/bin/env bash

NODE_MAJOR=18

poetry install --no-root
echo "export PROFILE=docker" >> ~/.bashrc

curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - &&\
apt-get install -y nodejs

npm install -g --save-dev --save-exact prettier
npm install -g editorconfig
npm install -g --save-dev editorconfig-checker

echo "function prettier() { npm exec prettier $@; }" >> ~/.bashrc
