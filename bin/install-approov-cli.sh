#!/bin/sh

set -eu

Main() {
  mkdir -p ~/.local/bin
  curl -L -O https://approov.io/downloads/approovcli.zip
  unzip approovcli.zip
  rm -rf approovcli.zip
  mv approovcli/Linux/approov ~/.local/bin/approov
  rm -rf approovcli
  echo
  approov || true
}

Main
