#!/bin/bash

echo "Download nvm script....."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

source ${HOME}/.bashrc

nvm install stable
nvm use stable

echo "Check Node.js version....."

node --version

echo "Check NPM version....."

npm --version

echo "Install html-minifier package globally....."

npm install html-minifier -g

echo "Check uglify-js command....."

uglifyjs --version
