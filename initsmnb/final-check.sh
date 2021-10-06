#!/bin/bash

# After all customizations applied, do a final check and display next steps
# to have the customizations in-effect.

cat << EOF


###############################################################################
# Customizations applied. Next, follow these steps to see them in-effect.     #
#                                                                             #
# First, restart the Jupyter process:                                         #
#                                                                             #
#     sudo initctl restart jupyter-server --no-wait                           #
#                                                                             #
# After the command, the Jupyter interface will probably freeze, which is     #
# expected.

#
# Then, refresh your browser tab, and enjoy the new experience.               #
EOF

GIT_VERSION=$(git --version)
if [[ "$GIT_VERSION" < "git version 2.28" ]]; then
    cat << EOF
#                                                                             #
#-----------------------------------------------------------------------------#
# NOTES:                                                                      #
#-----------------------------------------------------------------------------#
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
