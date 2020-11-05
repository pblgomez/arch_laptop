#!/usr/bin/env bash

sudo pacman -Sy ansible
ansible-galaxy install -r requirements.txt
