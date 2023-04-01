#!/bin/bash

set -euo pipefail

################################################################################
# STEP-00: environment variables related to CDK
################################################################################
cat << 'EOF' >> ~/.bashrc

# NVM installation after this env. var. is effective should survive reboots.
export NVM_DIR=$HOME/SageMaker/.initsmnb.d/.nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # Loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"  # Loads nvm bash_completion
EOF


################################################################################
# STEP-01: helper functions to install cdk (only when not installed yet).
################################################################################
# Activate for the current shell.
export NVM_DIR=$HOME/SageMaker/.initsmnb.d/.nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # Loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"  # Loads nvm bash_completion

detect_cmd() {
    "$@" &> /dev/null
    [[ $? == 0 ]] && echo "detected" || echo "not_detected"
}

mkdir -p $NVM_DIR

# Install nvm to NVM_DIR
if [[ $(detect_cmd nvm) == "not_detected" ]]; then
    echo "Installing nvm..."
    NVM_VERSION=$(curl -sL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.name')
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
    [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # Loads nvm
    [[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"  # Loads nvm bash_completion
fi
echo "Checking nvm:" `nvm --version`

# Install node.js (use lts version as-per CDK recommendation)
if [[ \
    ( $(detect_cmd node -e "console.log('Running Node.js ' + process.version)") == "not_detected" ) \
    || ( "$(which node)" == /home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/node ) \
]]; then
    echo "Installing node.js and npm..."
    GLIBC_VERSION=$(rpm -q --queryformat '%{version}' glibc)
    if [[ "$GLIBC_VERSION" > "2.26" ]]; then
        nvm install --lts
        nvm use --lts
    else
        echo "Old glibc-$GLIBC_VERSION detected. Falling back to node.js v16."
        nvm install 16
        nvm use 16
    fi
    npm install -g npm
fi

node -e "console.log('Running Node.js ' + process.version)"
echo "Checking npm:" `npm -v`

# Install CDK
if [[ $(detect_cmd cdk --version) == "not_detected" ]]; then
    echo "Installing cdk..."
    npm install -g aws-cdk
fi

# Run once, and see if there's any warning re. incompatible node.js version
echo "CDK version:" $(cdk --version)
