#!/bin/bash

echo "Download nvm script....."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

source "${HOME}/.nvm/nvm.sh" && nvm install stable
source "${HOME}/.nvm/nvm.sh" && nvm use stable

echo "Check Node.js version....."

source "${HOME}/.nvm/nvm.sh" && node --version

echo "Check NPM version....."

source "${HOME}/.nvm/nvm.sh" && npm --version

echo "Install html-minifier package globally....."

source "${HOME}/.nvm/nvm.sh" && npm install html-minifier -g

echo "Check uglify-js command....."

source "${HOME}/.nvm/nvm.sh" && uglifyjs --version
