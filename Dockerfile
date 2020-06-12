FROM debian:10-slim

RUN \
  apt update && \
  apt -y upgrade && \
  apt -y install \
    unzip \
    curl && \

  useradd -m -u 1000 -s /bin/bash approov

USER approov

WORKDIR /home/approov

ADD --chown=approov ./bin/install-approov-cli.sh /home/approov/bin/install-approov-cli.sh
ADD --chown=approov ./bin/monitor.bash /home/approov/monitor/monitor.bash

ENV PATH=/home/approov/.local/bin:/home/approov/bin:$PATH

RUN \
  ls -al ~/bin && \
  ~/bin/install-approov-cli.sh

WORKDIR /home/approov/monitor
