#!/bin/bash

set -eu

Show_Help() {
  printf "
USAGE:

./monitor [check|dry-run|forever]

COMMANDS:

check     Checks all the APIs and sends an email with the result.
          $ ./monitor check

dry-run   Checks all the APIs but doesn't send an email.
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

Send_Daily_Email() {

  local _subject="${1? Missing subject for the email.}"
  local _message=${2? Missing email message.}
  local _datetime="${3? Missing date time.}"

  local _now_timestamp=$(date -d "${_datetime}" +%s)
  local _last_email_datetime=$(cat .last-daily-email-sent)
  local _last_email_timestamp=$(date -d "${_last_email_datetime}" +%s)
  local _diff=$((${_now_timestamp} - ${_last_email_timestamp}))

  # Only send an email when the last daily sent email was 1 day ago.
  if [ "${_diff}" -ge "86400" ]; then
      printf "\n SENDING THE DAILY EMAIL. Last daily email sent ${_diff} seconds ago...\n\n"

      Send_Email "${_subject} - Daily Report - ${_datetime}" "${_message}"

      echo "${_datetime}" > .last-daily-email-sent
  else
      printf "\n NOT SENDING THE DAILY EMAIL. Last daily email sent ${_diff} seconds ago...\n\n"
  fi
}

Check_Apis() {

  local _is_dry_run=${1:-false}

  local _result
  local _subject="Approov TLS Certificates Monitor"
  local _datetime="$(date '+%c')"
  local _email_sent="false"

  if _result=$(approov api "${APPROOV_CLI_DEVELOPMENT_TOKEN_FILE}" -check); then
    printf "\nNo problems found with the certificates for all your API's:\n"
    printf "\n${_result}\n\n"
  else
    printf "\nFound some issues with the certificates for some of your API's:\n"
    printf "\n${_result}\n\n"

    # No matter what EMAIL_ALERT_POLICY we always send an email on FAILURE,
    # unless we are in a dry run.
    if [ "${_is_dry_run}" = "false" ]; then
      Send_Email "${_subject} - Checks Failed - ${_datetime}" "${_result}"
      local _email_sent="true"
    fi
  fi

  # Email is always sent on a check FAILURE, thus we only apply the
  # EMAIL_ALERT_POLICY when we are not in a dry run and the email was not
  # already sent.
  if [ "${_is_dry_run}" = "false" ] && [ "${_email_sent}" = "false" ]; then
    case "${EMAIL_ALERT_POLICY}" in
      "always" )
        Send_Email "${_subject} - Checks Passed  - ${_datetime}" "${_result}"
      ;;

      "daily" )
        Send_Daily_Email "${_subject}" "${_result}" "${_datetime}"
      ;;
    esac
  fi
}

Start_Forever_Monitor() {
  while true; do
    Check_Apis
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
        Check_Apis
        exit $?
      ;;

      dry-run )
        shift 1
        Check_Apis "true"
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
