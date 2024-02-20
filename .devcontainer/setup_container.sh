#!/usr/bin/env bash

poetry install --no-root
echo "export PROFILE=docker" >> ~/.bashrc

npm install -g --save-dev --save-exact prettier
npm install -g editorconfig
npm install -g --save-dev editorconfig-checker
