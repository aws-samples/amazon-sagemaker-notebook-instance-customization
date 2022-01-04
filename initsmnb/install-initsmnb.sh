#!/bin/bash

################################################################################
# Must run only on a SageMaker classic notebook instance.
################################################################################
if [[ -d /var/log/studio/ ]]; then
    cat << EOF

###########################################################################
# Installation declined.                                                  #
#                                                                         #
# Reason: /var/log/studio/ detected; probably this is a Studio notebook.  #
#                                                                         #
# Please make sure to run the installation script on a SageMaker classic  #
# notebook instance.                                                      #
#                                                                         #
# If you still insists to proceed with the installation, please fork the  #
# repo, edit the installation script to disable the relevant check. And   #
# when you go this route, you're assumed to be proficient in shell        #
# scriptings, and thus, able to navigate your way with the scripts.       #
###########################################################################

EOF
    exit 1
fi


if [[ ! -f /etc/opt/ml/sagemaker-notebook-instance-config.json ]]; then
    cat << EOF

#############################################################################
# Installation declined.                                                    #
#                                                                           #
# Reason: /etc/opt/ml/sagemaker-notebook-instance-config.json not detected; #
# probably this is not a classic notebook instance.                         #
#                                                                           #
# Please make sure to run the installation script on a SageMaker classic    #
# notebook instance.                                                        #
#                                                                           #
# If you still insist to proceed with the installation, please fork the     #
# repo, edit the installation script to disable the relevant check. And     #
# when you go this route, you're assumed to be proficient in shell          #
# scriptings, and thus, able to navigate your way with the scripts.         #
#############################################################################

EOF
    exit 2
fi


################################################################################
# Global vars
################################################################################
INITSMNB_DIR=~/SageMaker/initsmnb
SRC_PREFIX=https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-customization/main/initsmnb
# Uncomment for testing remote install from local source
#SRC_PREFIX=file:///home/ec2-user/SageMaker/amazon-sagemaker-notebook-instance-customization/initsmnb

declare -a SCRIPTS=(
    TEMPLATE-setup-my-sagemaker.sh
    ensure-smnb.sh
    install-cli.sh
    adjust-sm-git.sh
    fix-osx-keymap.sh
    patch-bash-config.sh
    fix-ipython.sh
    init-vim.sh
    install-cdk.sh
    QUICKSTART-CDK.md
    fix-pyspark-smnb.sh
    mount-efs-accesspoint.sh
    patch-jupyter-config.sh
    change-jlab-ui.sh
    final-check.sh
    enable-sm-local-mode.sh
    change-docker-data-root.sh
    change-docker-tmp-dir.sh
    restart-docker.sh
)

declare -a NESTED_FILES=(
    .ipython/profile_default/startup/01-osx-jupyterlab-keys.py
)

CURL_OPTS="--fail-early -fL"

FROM_LOCAL=0
GIT_USER=''
GIT_EMAIL=''
declare -a EFS=()

declare -a HELP=(
    "[-h|--help]"
    "[-l|--from-local]"
    "[--git-user 'First Last']"
    "[--git-email me@abc.def]"
    "[--efs 'fsid,fsap,mp' [--efs ...]]"
)

################################################################################
# Helper functions
################################################################################
error_and_exit() {
    echo "$@" >&2
    exit 1
}

parse_args() {
    local key
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h|--help)
            echo "Install initsmnb."
            echo "Usage: $(basename ${BASH_SOURCE[0]}) ${HELP[@]}"
            exit 0
            ;;
        -l|--from-local)
            FROM_LOCAL=1
            shift
            ;;
        --git-user)
            GIT_USER="$2"
            shift 2
            ;;
        --git-email)
            GIT_EMAIL="$2"
            shift 2
            ;;
        --efs)
            [[ "$2" != "" ]] && EFS+=("$2")
            shift 2
            ;;
        *)
            error_and_exit "Unknown argument: $key"
            ;;
        esac
    done
}

efs2str() {
    local sep="${1:-|}"
    if [[ ${#EFS[@]} -gt 0 ]]; then
        printf "'%s'${sep}" "${EFS[@]}"
    else
        echo "''"
    fi
}

exit_on_download_error() {
    cat << EOF

###############################################################################
# ERROR
###############################################################################
# Could not downloading files from:
#
# $SRC_PREFIX/
#
# Please check and ensure your SageMaker classic notebook instance has the
# necessary network access to download files from the source repository.
###############################################################################

EOF
    exit -1
}


################################################################################
# Main
################################################################################
parse_args "$@"
echo "GIT_USER='$GIT_USER'"
echo "GIT_EMAIL='$GIT_EMAIL'"
echo "EFS=$(efs2str)"

mkdir -p $INITSMNB_DIR

if [[ $FROM_LOCAL == 0 ]]; then
    cd $INITSMNB_DIR
    echo "Downloading scripts from ${SRC_PREFIX}/"
    echo
    curl $CURL_OPTS -O $SRC_PREFIX/{$(echo "${SCRIPTS[@]}" | tr ' ' ',')}
    [[ $? == 22 ]] && exit_on_download_error
    chmod ugo+x ${SCRIPTS[@]}

    # Nested scripts need 1 curl/file
    for i in "${NESTED_FILES[@]}"; do
        curl $CURL_OPTS --create-dirs -o $i $SRC_PREFIX/$i
        [[ $? == 22 ]] && exit_on_download_error
    done
else
    BIN_DIR=$(dirname "$(readlink -f ${BASH_SOURCE[0]})")
    cd $INITSMNB_DIR
    echo "Copying scripts from $BIN_DIR"
    cp -a ${BIN_DIR}/* .
    cp -a ${BIN_DIR}/.ipython .
    chmod ugo+x *.sh
fi

echo "Generating setup-my-sagemaker.sh"
echo "=> git-user / git-email = '$GIT_USER' / '$GIT_EMAIL'"
echo "=> EFS: (fsid,fsap,mountpoint)|... = $(efs2str)"
cat << EOF > setup-my-sagemaker.sh
#!/bin/bash

# Auto-generated from TEMPLATE-setup-my-sagemaker.sh by install-initsmnb.sh

EOF

sed \
    -e "s/Firstname Lastname/$GIT_USER/" \
    -e "s/first.last@email.abc/$GIT_EMAIL/" \
    -e "s/fsid,fsapid,mountpoint/$(efs2str ' ')/" \
    TEMPLATE-setup-my-sagemaker.sh >> setup-my-sagemaker.sh
chmod ugo+x setup-my-sagemaker.sh

# Delete mount script if no efs requested.
# WARNING: when testing on OSX, next line must use gsed.
[[ "${#EFS[@]}" < 1 ]] && sed -i "/mount-efs-accesspoint.sh/d" setup-my-sagemaker.sh

EPILOGUE=$(cat << EOF

####################################################
# Installation completed.                          #
#                                                  #
# You may want to enable optional tweaks in file   #
# ~/SageMaker/initsmnb/setup-my-sagemaker.sh       #
#                                                  #
# To change this session, run:                     #
#                                                  #
#     ~/SageMaker/initsmnb/setup-my-sagemaker.sh   #
#                                                  #
# On notebook restart, also run that same command. #
####################################################
EOF
)
echo -e "${EPILOGUE}\n"

cd $OLDPWD
