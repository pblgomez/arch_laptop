#!/usr/bin/env sh
#
#    _ \  |      |
#   |   | __ \   |  Pablo Gómez
#   ___/  |   |  |  http://www.gitlab.com/pblgomez
#  _|    _.__/  _|
#
# Description: Post Instalation of Archlinux

sudo pacman -Sy ansible --noconfirm
ansible-galaxy install -r requirements.yml
ansible-playbook site.yml -K
