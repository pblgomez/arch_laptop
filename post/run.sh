#!/usr/bin/env bash

sudo pacman -Sy ansible --noconfirm
ansible-galaxy install -r requirements.yml
ansible-playbook site.yml -K
