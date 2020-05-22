#!/bin/bash

echo "Download nvm script....."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

source ${HOME}/.bashrc && nvm install stable
source ${HOME}/.bashrc && nvm use stable

echo "Check Node.js version....."

source ${HOME}/.bashrc && node --version

echo "Check NPM version....."

source ${HOME}/.bashrc && npm --version

echo "Install html-minifier package globally....."

source ${HOME}/.bashrc && npm install html-minifier -g

echo "Check uglify-js command....."

source ${HOME}/.bashrc && uglifyjs --version
