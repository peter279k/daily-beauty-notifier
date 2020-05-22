# daily-beauty-notifier

## Introduction

A simple Bash script is for fetching some beauty images and send newsletter via SendinBlue every day.

## Installation

- Clone this Git repository via `git clone https://github.com/peter279k/daily-beauty-notifier`
- Setting `sendinblue_api_key` as a environment variable.
- If the `html-minifier` command on current environment, running `html_minifier_installer.sh` Bash script.
- Create `mail_addresses.txt` and content formats are as follows:
```
user1@mail.com
user2@mail.com
......
```
- Create `mail_setting.csv` and the content formats are as follows:
```
"subject","正妹日報(today_date)"
"sender_name","Your Sender Name"
"sender_email","Your Sender E-mail address"
```
- Run `daily_beauty_notifier.sh` as a Cronjob!
- Done. Enjoy it!

## Uninstallation

- Unset `sendinblue_api_key` environment variable
- Remove `daily-beauty-notifier` repository folder via `rm -rf daily-beauty-notifier/`
- Delete related `./daily_beauty_notifier.sh` Cronjob.
- Remove `$NVM_DIR` via `rm -rf ${NVM_DIR}` to remove nvm directory.
- Remove following lines on `${HOME}/.bashrc` file:
```
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```
