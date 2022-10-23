#!/bin/bash

mkdir -p \
    ~/.local/share/ \
    ~/SageMaker/.initsmnb.d/.local/share/code-server/ \

[[ -d ~/.local/share/code-server ]] \
    || ln -s ~/SageMaker/.initsmnb.d/.local/share/code-server ~/.local/share/code-server

curl -fsSL https://code-server.dev/install.sh | sh
rm -fr ~/.cache/code-server/

SMNB_NAME=$(cat /opt/ml/metadata/resource-metadata.json  | jq -r '.ResourceName')
SMNB_URL=$(cat /etc/opt/ml/sagemaker-notebook-instance-config.json \
     | jq -r '.notebook_uri' \
     | sed 's/[\\()]//g' \
     | sed "s/|${SMNB_NAME}\.notebook/.notebook/"
)
echo "################################################################################"
echo "# Steps to run VSCode"
echo "################################################################################"
echo "1. Open the terminal and run:"
echo
echo "       code-server --auth-none"
echo
echo "2. Then, open a new browser tab and go to:"
echo
echo "       $SMNB_URL/proxy/8080/"
echo "################################################################################"

# --user-data-dir
# --extension-dir
# --install-extension

rm -fr
    ~/.local/share/code-server/CachedExtensionVSIXs/ \
    ~/.local/share/code-server/CachedExtensions/

#{
#    "workbench.colorTheme": "Default Dark+",
#    "workbench.startupEditor": "none",
#    "editor.cursorBlinking": "solid"
#}
