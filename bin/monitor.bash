#!/bin/bash

set -eu

Show_Help() {
  printf "
USAGE:

./monitor [check|dry-run|forever]

COMMANDS:

check     Checks all the APIs and sends an email with the result.
          $ ./monitor check

dry-run   Checks all the APIs but not send an email.
          $ ./monitor dry-run

forever   Same as the check command, but runs forever and sleeps between checks.
          $ ./monitor forever

"
}

Send_Email() {

  local _subject=${1? Missing email subject.}
  local _message=${2? Missing email message.}

  curl \
    --url "smtps://${SMTP_SERVER_ADDRESS}" \
    --ssl-reqd \
    --mail-from "${USER_EMAIL}" \
    --mail-rcpt "${TO_EMAIL}" \
    --user "${USER_EMAIL}:${USER_PASSWORD}" \
    -T <(echo -e "From: ${USER_EMAIL} \nTo: ${TO_EMAIL} \nSubject: ${_subject} \n\n${_message}")
}

Check_Apis() {
  local _is_to_send_email=${1:-false}
  local _result

  if _result=$(approov api "${APPROOV_CLI_DEVELOPMENT_TOKEN_FILE}" -check); then
    printf "\nNo problems found with the certificates for all your API's:\n"
    printf "\n${_result}\n\n"
    local _subject="No issues"
  else
    printf "\nFound some issues with the certificates for some of your API's:\n"
    printf "\n${_result}\n\n"
    local _subject="Found some issues"
  fi

  if [ "${_is_to_send_email}" = "true" ]; then
    Send_Email "Approov TLS Certificates Monitor - ${_subject} - $(date '+%c')" "${_result}"
  fi
}

Check_Apis_And_Send_Alert_Email() {
  Check_Apis "true"
}

Start_Forever_Monitor() {
  while true; do
    Check_Apis_And_Send_Alert_Email
    sleep "${CHECK_INTERVAL_IN_MINUTES}m"
  done
}

Main() {

  if [ ! -f ./.env ]; then
    printf "\n---> Please copy the .env.example file and update it with your values.\n\n"
    exit 1
  fi

  . ./.env

  for input in  "${@}"; do
    case "${input}" in
      check )
        shift 1
        Check_Apis_And_Send_Alert_Email
        exit $?
      ;;

      dry-run )
        shift 1
        Check_Apis
        exit $?
      ;;

      forever )
        shift 1
        Start_Forever_Monitor
        exit $?
      ;;

      * )
        Show_Help
        exit 0
      ;;
    esac
  done

  Show_Help
}

Main $@
