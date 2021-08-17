#!/bin/bash

# Utility function to get script's directory (deal with Mac OSX quirkiness).
# This function is ambidextrous as it works on both Linux and OSX.
get_bin_dir() {
    local READLINK=readlink
    if [[ $(uname) == 'Darwin' ]]; then
        READLINK=greadlink
        if [ $(which greadlink) == '' ]; then
            echo '[ERROR] Mac OSX requires greadlink. Install with "brew install greadlink"' >&2
            exit 1
        fi
    fi

    local BIN_DIR=$(dirname "$($READLINK -f ${BASH_SOURCE[0]})")
    echo -n ${BIN_DIR}
}

BIN_DIR=$(get_bin_dir)

# Install some useful CLI toolkits
sudo yum install -y htop tree dstat dos2unix tig
sudo /usr/bin/pip3 install --no-cache-dir nbdime ranger-fm
mkdir -p /home/ec2-user/.config/ranger/
echo set line_numbers relative >> /home/ec2-user/.config/ranger/rc.conf

${BIN_DIR}/adjust-sm-git.sh 'Firstname Lastname' first.last@email.abc
${BIN_DIR}/change-fontsize.sh
${BIN_DIR}/fix-osx-keymap.sh
${BIN_DIR}/patch-bash-config.sh
${BIN_DIR}/fix-ipython.sh
${BIN_DIR}/init-vim.sh
${BIN_DIR}/mount-efs-accesspoint.sh fsid,fsapid,mountpoint

# These require jupyter lab restarted and browser reloaded, to see the changes.
${BIN_DIR}/patch-jupyter-config.sh
