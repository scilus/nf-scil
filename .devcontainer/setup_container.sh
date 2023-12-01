#!/usr/bin/env bash

poetry install --no-root
echo "export PROFILE=docker" >> ~/.bashrc

