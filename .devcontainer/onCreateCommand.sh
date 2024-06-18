#!/usr/bin/env bash

npm install -g --save-dev --save-exact prettier
npm install -g editorconfig
npm install -g --save-dev editorconfig-checker

mkdir -p $XDG_CONFIG_HOME/nf-scil
touch $XDG_CONFIG_HOME/nf-scil/.env
echo "source $XDG_CONFIG_HOME/nf-scil/.env" >> ~/.bashrc
