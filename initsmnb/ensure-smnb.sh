#!/bin/bash

if [[ -d /var/log/studio/ ]]; then
    cat << EOF

###########################################################################
# Customizations declined.                                                #
#                                                                         #
# Reason: /var/log/studio/ detected; probably this is a Studio notebook.  #
#                                                                         #
# Please make sure to run ~/SageMaker/initsmnb/setup-my-sagemaker.sh on   #
# a SageMaker classic notebook instance.                                  #
#                                                                         #
# If you still insists to proceed with customizations, please edit        #
# ~/SageMaker/initsmnb/setup-my-sagemaker.sh and disable the relevant     #
# check. And when you go this route, you're assumed to be proficient in   #
# shell scriptings, and thus, able to navigate your way with the scripts. #
###########################################################################

EOF
    exit 1
fi


if [[ ! -f /etc/opt/ml/sagemaker-notebook-instance-config.json ]]; then
    cat << EOF

#############################################################################
# Customizations declined.                                                  #
#                                                                           #
# Reason: /etc/opt/ml/sagemaker-notebook-instance-config.json not detected; #
# probably this is not a classic notebook instance.                         #
#                                                                           #
# Please make sure to run ~/SageMaker/initsmnb/setup-my-sagemaker.sh on a   #
# SageMaker classic notebook instance.                                      #
#                                                                           #
# If you still insist to proceed with customizations, please edit           #
# ~/SageMaker/initsmnb/setup-my-sagemaker.sh and disable the relevant       #
# check. And when you go this route, you're assumed to be proficient in     #
# shell scriptings, and thus, able to navigate your way with the scripts.   #
#############################################################################

EOF
    exit 2
fi

exit 0
