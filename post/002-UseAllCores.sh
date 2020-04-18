#!/usr/bin/env bash
var=$(nproc)
echo "############################################################"
echo "Detected $var Cores"
echo "############################################################"
var=$(($var+1))

sudo sed -i 's/.*MAKEFLAGS=.*/MAKEFLAGS="-j'$var'"/g' /etc/makepkg.conf
sudo sed -i 's/COMPRESSXZ=.*/COMPRESSXZ=(xz -c -T '$var' -z -)/g' /etc/makepkg.conf
