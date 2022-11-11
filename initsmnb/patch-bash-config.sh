#!/bin/bash

cat << 'EOF' >> ~/.bash_profile

# Workaround: when starting tmux from conda env, deactivate in all tmux sessions.
if [[ ! -z "$TMUX" ]]; then
    for i in $(seq $CONDA_SHLVL); do
        conda deactivate
    done
fi
EOF


# PS1 must preceed conda bash.hook, to correctly display CONDA_PROMPT_MODIFIER
cp ~/.bashrc{,.ori}
cat << 'EOF' > ~/.bashrc
git_branch() {
   local branch=$(/usr/bin/git branch 2>/dev/null | grep '^*' | colrm 1 2)
   [[ "$branch" == "" ]] && echo "" || echo "($branch) "
}

# All colors are bold
COLOR_GREEN="\[\033[1;32m\]"
COLOR_PURPLE="\[\033[1;35m\]"
COLOR_YELLOW="\[\033[1;33m\]"
COLOR_OFF="\[\033[0m\]"

# Define PS1 before conda bash.hook, to correctly display CONDA_PROMPT_MODIFIER
export PS1="[$COLOR_GREEN\w$COLOR_OFF] $COLOR_PURPLE\$(git_branch)$COLOR_OFF\$ "
EOF


# Original .bashrc content
cat ~/.bashrc.ori >> ~/.bashrc

# Custom aliases
cat << 'EOF' >> ~/.bashrc

alias ll='ls -alF --color=auto'

# Better dir color on dark terminal: changed from dark blue to lighter blue
export LS_COLORS="di=38;5;39"

man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		man "$@"
}
EOF

#echo "On a new SageMaker terminal, which uses 'sh' by default, type 'bash -l' (without the quotes)"

###############################################################################
# A few useful AWS environment variables
###############################################################################
# To speed-up shell initialization, locks to setup-time's EC2 instance.
ACCOUNT=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | sed -e 's/"//g' -e 's/,//g')
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]\$//'`"

SMNB_NAME=$(cat /opt/ml/metadata/resource-metadata.json  | jq -r '.ResourceName')
SMNB_URL=$(cat /etc/opt/ml/sagemaker-notebook-instance-config.json \
    | jq -r '.notebook_uri' \
    | sed 's/[\\()]//g' \
    | sed "s/|${SMNB_NAME}\.notebook/.notebook/"
)

# Add environment variables
cat << EOF >> ~/.bashrc

# Non-standard environment variables
export AWS_ACCOUNT=$ACCOUNT
export EC2_AVAIL_ZONE=$EC2_AVAIL_ZONE

# AWS CLI's environment variables
# Fallback to ~/.aws/config
#export AWS_DEFAULT_REGION=$REGION
#export AWS_REGION=$REGION

# CDK's environment variables
export CDK_DEFAULT_ACCOUNT=$ACCOUNT
export CDK_DEFAULT_REGION=$REGION

# SageMaker notebook variables
export SMNB_NAME=$SMNB_NAME
export SMNB_URL=$SMNB_URL
EOF

# Provide reference on how to regenerate the values.
cat << 'EOF' >> ~/.bashrc

################################################################################
# NOTE: this noticeably slows down shell initialization by another ~3 second.
# It's left as a reference in case you want to regenerate the above values.
################################################################################
#AWS_ACCOUNT=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | sed -e 's/"//g' -e 's/,//g')
#EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
#AWS_DEFAULT_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]\$//'`"
################################################################################

################################################################################
# NOTE: these are left as a left as a reference in case you want to regenerate
# the above values.
################################################################################
#SMNB_NAME=$(cat /opt/ml/metadata/resource-metadata.json  | jq -r '.ResourceName')
#SMNB_URL=$(cat /etc/opt/ml/sagemaker-notebook-instance-config.json \
#    | jq -r '.notebook_uri' \
#    | sed 's/[\\()]//g' \
#    | sed "s/|${SMNB_NAME}\.notebook/.notebook/"
#)
################################################################################
EOF
