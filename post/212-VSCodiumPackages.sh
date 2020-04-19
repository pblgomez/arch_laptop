#!/usr/bin/env bash
set -e

ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if hash vscodium 2>/dev/null; then
  while IFS= read -r package
    do
    if ls $HOME/.vscode-oss/extensions/$package* 1> /dev/null 2>&1; then
      echo "Already installed $package"
    else
      echo "Installing $package"
      vscodium --install-extension $package
    fi
  done < $ThisDir/vscode-packages.txt

  echo "----------------------------------------------------------------------"
  echo "     Configuring VSCodium..."
  echo "----------------------------------------------------------------------"
  file=~/.config/VSCodium/User/settings.json
  if [ ! -f $file ]; then
    touch $file
    cat <<EOT > $file
{
  "editor.tabSize": 2,
  "files.trimTrailingWhitespace": true,
  "files.trimFinalNewlines": true,
  "files.autoSave": "afterDelay",
  "editor.lineNumbers": "relative",
  "workbench.colorTheme": "Dracula"
}
EOT
  fi
  if ! grep -q '"editor.lineNumbers": "relative"' $file; then
    sed -i '/}/i \    "editor.lineNumbers": "relative"' $file
  fi
fi