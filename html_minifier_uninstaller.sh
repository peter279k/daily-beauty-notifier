#!/bin/bash

echo 'In only supports for Bash script!'

rm -rf ${HOME}/.nvm

sed -i -e 's@export NVM_DIR="$HOME/.nvm"@@g' "${HOME}/.bashrc"
sed -i -e 's@[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm@@g' "${HOME}/.bashrc"
sed -i -e 's@[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion@@g' "${HOME}/.bashrc"
