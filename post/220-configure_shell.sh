#!/usr/bin/env bash
set -e

echo "----------------------------------------------------------------------"
echo "     Selecting shell"
echo "----------------------------------------------------------------------"
if [ -f /usr/bin/zsh ] && [ $SHELL != /usr/bin/zsh ]; then
  chsh -s $(cat /etc/shells | grep zsh | head -n1)
  echo '
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Start graphical server on tty1 if not already running.
[ "$(tty)" = "/dev/tty1" ] && ! pgrep -x Xorg >/dev/null && exec startx
  ' | sudo tee -a /etc/zsh/zshenv
fi