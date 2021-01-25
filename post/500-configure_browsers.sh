#!/usr/bin/env bash
set -e

if hash firefox 2>/dev/null; then
	mkdir -p "$HOME"/.config/mozilla/firefox
	firefox --CreateProfile '"$USER" "$HOME"/.config/mozilla/firefox/"$USER"'
fi
