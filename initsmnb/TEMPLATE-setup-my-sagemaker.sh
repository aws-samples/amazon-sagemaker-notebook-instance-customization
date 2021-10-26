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

# Placeholder to store persistent config files
mkdir -p ~/SageMaker/.initsmnb.d

# Hold symlinks of select binaries from the 'base' conda environment, so that
# custom environments don't have to install them, e.g., nbdime, docker-compose.
mkdir -p ~/.local/bin

${BIN_DIR}/install-cli.sh
${BIN_DIR}/adjust-sm-git.sh 'Firstname Lastname' first.last@email.abc
${BIN_DIR}/change-fontsize.sh
${BIN_DIR}/fix-osx-keymap.sh
${BIN_DIR}/patch-bash-config.sh
${BIN_DIR}/fix-ipython.sh
${BIN_DIR}/init-vim.sh
${BIN_DIR}/mount-efs-accesspoint.sh fsid,fsapid,mountpoint

# These require jupyter lab restarted and browser reloaded, to see the changes.
${BIN_DIR}/patch-jupyter-config.sh

# Disable jupyterlab git extension
#~/anaconda3/envs/JupyterSystemEnv/bin/jupyter labextension disable '@jupyterlab/git'

# Enable SageMaker local mode
#ln -s ~/anaconda3/bin/docker-compose ~/.local/bin/
#curl -sfL \
#    https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-local-mode/main/blog/pytorch_cnn_cifar10/setup.sh \
#    | /bin/bash -s

# Final checks and next steps to see the changes in-effect
${BIN_DIR}/final-check.sh
