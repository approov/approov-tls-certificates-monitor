#!/bin/sh

set -eu

Main() {
  if [ ! -f ./.env ]; then
    printf "\n---> Please copy the .env.example file and update it with your values.\n\n"
    exit 1
  fi

  . ./.env

  printf "\n$ cat/etc/cron.d/approov-tls-certificates-monitor.service:\n\n"

  sudo tee /etc/cron.d/approov-tls-certificates-monitor.service <<EOF
PATH=/home/${USER}/.local/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# we need to cd into the dir, because the bash scripts needs to read the .env file.
*/${CHECK_INTERVAL_IN_MINUTES} * * * * ${USER} cd ${HOME}/.approov/approov-tls-certificates-monitor && ./bin/monitor.bash check

EOF

  printf "\nCron job is now running every ${CHECK_INTERVAL_IN_MINUTES} minutes.\n"
  printf "\nCheck the email ${TO_EMAIL} to see the result for the first run.\n\n"
}

Main
