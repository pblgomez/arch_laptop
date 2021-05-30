#!/usr/bin/env sh
#
#    _ \  |      |
#   |   | __ \   |  Pablo Gómez
#   ___/  |   |  |  http://www.gitlab.com/pblgomez
#  _|    _.__/  _|
#
# Description: Post Instalation of Archlinux

ThisDir=$(dirname "$(readlink -f -- "$0")")

sudo pacman -Sy ansible --noconfirm --needed
ansible-galaxy install -r "$ThisDir"/requirements.yml
ansible-playbook site.yml -Kk
