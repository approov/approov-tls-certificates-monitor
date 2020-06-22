#!/bin/sh

set -eu

Main() {

  if [ ! -f ./.env ]; then
    printf "\n---> Please copy the .env.example file and update it with your values.\n\n"
    exit 1
  fi

  . ./.env

  printf "\n$ cat /etc/cron.d/approov-tls-certificates-monitor.service:\n\n"

  sudo tee /etc/systemd/system/approov-tls-certificates-monitor.service <<EOF
[Unit]
Description=Starts the Approov Tls Certificates Monitor service

[Service]
User=${USER}
Group=${USER}
Environment="PATH=${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
ExecStart=/bin/bash -c "cd /home/exadra37/Developer/Remote/Approov2/Monitor/letsencrypt && ./bin/monitor.bash forever"

[Install]
WantedBy=default.target
EOF

  echo
  sudo systemctl start approov-tls-certificates-monitor

  echo
  sudo systemctl enable approov-tls-certificates-monitor

  printf "\nThe systemd service is now running every ${CHECK_INTERVAL_IN_MINUTES} minutes.\n"
  printf "\nCheck the email ${TO_EMAIL} to see the result for the first run.\n"

  printf "\nSee the status for the systemd service with:\n"
  printf "\n$ sudo systemctl status approov-tls-certificates-monitor\n\n"
}

Main
