#!/bin/bash

set -euo pipefail

# Constants
APP=s5cmd
GH=peak/s5cmd

[[ -e ~/.local/bin/s5cmd ]] && exit

mkdir -p ~/.local/bin
cd ~/.local/bin

latest_download_url() {
  if [[ $(uname -i) == "x86_64" ]]; then
    local goarch=64bit
  else
    echo WARNING: to test that this works on gravition, and the need for more precise condition
    local goarch=arm64
  fi
  curl --silent "https://api.github.com/repos/${GH}/releases/latest" |   # Get latest release from GitHub api
    grep "\"browser_download_url\": \"https.*$(uname)-$goarch.tar.gz" |  # Get download url
    sed -E 's/.*"([^"]+)".*/\1/'                                         # Pluck JSON value
}


LATEST_DOWNLOAD_URL=$(latest_download_url)
TARBALL=${LATEST_DOWNLOAD_URL##*/}
curl -LO ${LATEST_DOWNLOAD_URL}

# Go tarball has no root, so we need to create one
DIR=${TARBALL%.tar.gz}
mkdir -p $DIR && cd $DIR && tar -xzf ../$TARBALL && cd .. && rm $TARBALL

[[ -L ${APP}-latest ]] && rm ${APP}-latest
ln -s $DIR ${APP}-latest
ln -s ${APP}-latest/${APP} .
