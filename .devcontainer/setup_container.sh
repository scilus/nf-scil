#!/usr/bin/env bash

poetry install

echo "poetry shell" >> ~/.bashrc
echo "export PROFILE=docker" >> ~/.bashrc
