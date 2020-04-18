#!/usr/bin/env bash
set -e


# To remove the remote origin
# git remote rm origin

# To add a remote origin in case you want to use ssh
# git remote add origin git@gitlab.com:pblgomez/antergosfscratch.git




echo "----------------------------------------------------------------------"
echo "First edit variables file and write your own details"
echo "Don't continue if you haven't done it. Crtl+c to cancel"
echo "----------------------------------------------------------------------"
sleep 3s

ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $ThisDir/variables
git config --global user.name $name
git config --global user.email $email
sudo git config --system core.editor $EDITOR

mv $HOME/.gitconfig $HOME/.config/git/config