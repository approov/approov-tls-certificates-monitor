#!/bin/sh

set -eu

Show_Help() {
  printf "
USAGE:

./stack [build|run|up|shell]

COMMANDS:

build         Build the docker image.
              $ ./stack build

run check     Checks all the APIs and sends an email with the result.
              $ ./stack run check

run dry-run   Checks all the APIs but doesn't send an email.
              $ ./stack run dry-run

up forever    Same as the check command, but runs forever and sleeps between checks.
              $ ./stack up forever

shell         Runs a bash shell inside a new docker container
              $ ./stack shell
              $ ./stack shell sh
              $ ./stack shell ./monitor.bash dry-run

"
}

Docker_Run() {
  sudo docker run \
    ${options} \
    --name ${container_name} \
    --volume "${PWD}/.env":/home/approov/monitor/.env \
    --volume "${APPROOV_CLI_DEVELOPMENT_TOKEN_FILE}":"${APPROOV_CLI_DEVELOPMENT_TOKEN_FILE}" \
    "${docker_image}" ${@}
}

Main() {

  if [ ! -f ./.env ]; then
    printf "\n---> Please copy the .env.example file and update it with your values.\n\n"
    exit 1
  fi

  . ./.env

  local options="--rm"
  local container_name="approov-tls-certificates-monitor"
  local docker_image="approov/${container_name}"

  for input in "${@}"; do
    case "${input}" in
      build )
        sudo docker build --tag "${docker_image}" .
        exit $?
      ;;

      run )
        shift 1
        Docker_Run "./monitor.bash ${@}"
        exit $?
      ;;

      up )
        shift 1
        options="--restart unless-stopped --detach"
        Docker_Run "./monitor.bash" "forever"
        exit $?
      ;;

      down )
        sudo docker stop "${container_name}"
        sudo docker rm --force "${container_name}"
        exit $?
      ;;

      shell )
        shift 1
        local _shell_name="${1:-bash}"

        if [ "$#" -ge 1 ]; then
          shift 1
        fi

        options="--rm -it"
        Docker_Run "${_shell_name}" "${@}"
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

Main "${@}"
