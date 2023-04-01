#!/bin/bash

set -euo pipefail

# Constants
APP=duf
GH=muesli/duf

latest_download_url() {
  if [[ $(uname -i) == "x86_64" ]]; then
    local arch=amd64
  else
    echo WARNING: to test that this works on gravition, and the need for more precise condition
    local arch=arm64
  fi
  curl --silent "https://api.github.com/repos/${GH}/releases/latest" |   # Get latest release from GitHub api
    grep "\"browser_download_url\": \"https.*\/duf_.*_linux_$arch.rpm" |  # Get download url
    sed -E 's/.*"([^"]+)".*/\1/'                                         # Pluck JSON value
}

LATEST_DOWNLOAD_URL=$(latest_download_url)
RPM=${LATEST_DOWNLOAD_URL##*/}
(cd /tmp/ && curl -LO ${LATEST_DOWNLOAD_URL})

sudo yum localinstall -y /tmp/$RPM && rm /tmp/$RPM
