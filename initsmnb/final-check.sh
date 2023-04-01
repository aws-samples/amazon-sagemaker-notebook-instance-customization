#!/bin/bash

# Final remarks on why by default, initsmnb didn't update existing SageMaker packages
SM_PKG_TO_UPDATE=$(sudo yum -q check-update 2> /dev/null | wc -l)
COLOR_RED="\033[1;31m"
COLOR_OFF="\033[0m"
echo -e "
${COLOR_RED}Skip update of ${SM_PKG_TO_UPDATE}+ SageMaker-provided packages because it takes time.
${COLOR_OFF}If you still want to update these packages, do a ${COLOR_RED}sudo yum update${COLOR_OFF}.
"

# After all customizations applied, do a final check and display next steps
# to have the customizations in-effect.

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR == "Amazon Linux 2" ]]; then
    CMD_RESTART="sudo systemctl restart jupyter-server        "
else
    CMD_RESTART="sudo initctl restart jupyter-server --no-wait"
fi

cat << EOF


###############################################################################
# Customizations applied. Next, follow these steps to see them in-effect.     #
#                                                                             #
# First, restart the Jupyter process:                                         #
#                                                                             #
#     ${CMD_RESTART}                           #
#                                                                             #
# After the command, the Jupyter interface will probably freeze, which is     #
# expected.                                                                   #
#                                                                             #
# Then, refresh your browser tab, and enjoy the new experience.               #
EOF

if [[ -e ~/HOWTO-RUN-CODE-SERVER.txt ]]; then
    cat << 'EOF'
#                                                                             #
# --------------------------------------------------------------------------- #
# NOTES:                                                                      #
# --------------------------------------------------------------------------- #
# Please refer to file ~/HOWTO-RUN-CODE-SERVER.txt on how to use code-server  #
# (i.e., "VS Code in the browser") on this SageMaker notebook instance.       #
EOF

fi

GIT_VERSION=$(git --version)
if [[ "$GIT_VERSION" < "git version 2.28" ]]; then
    cat << 'EOF'
#                                                                             #
# --------------------------------------------------------------------------- #
# NOTES:                                                                      #
# --------------------------------------------------------------------------- #
# The git version on this SageMaker classic notebook instance is older than   #
# version 2.28, hence "git init" will default to branch "master".             #
#                                                                             #
# To initialize a new git repo with default branch "main", run:               #
#                                                                             #
#    git init; git checkout -b main                                           #
EOF
fi

cat << EOF
###############################################################################

EOF
