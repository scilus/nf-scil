#!/usr/bin/env bash

NODE_MAJOR=18

poetry install --no-root
echo "export PROFILE=docker" >> ~/.bashrc

mkdir /nodesource && cd /nodesource
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - &&\
apt-get install -y nodejs

npm install --save-dev --save-exact prettier

echo "function prettier() { npm exec prettier $@; }" >> ~/.bashrc
