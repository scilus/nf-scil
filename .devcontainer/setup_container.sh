#!/usr/bin/env bash

git submodules init

poetry install

echo "poetry shell" >> ~/.bashrc