#!/bin/bash

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR == "Amazon Linux 2" ]]; then
    # Slow install; hence disabled by default
    #sudo amazon-linux-extras install -y epel
    #sudo yum install -y tig
    sudo yum install -y htop tree dstat dos2unix
else
    sudo yum install -y htop tree dstat dos2unix tig
fi

~/anaconda3/bin/nbdime config-git --enable --global

# Pipx to install pre-commit. Otherwise, pre-commit is broken when installed
# with /usr/bin/pip3 (alinux), but we don't want to use ~/anaconda/bin/pip3
# either to minimize polluting its site packages.
~/anaconda3/bin/pip3 install --no-cache-dir pipx

# Relocate pipx packages to ~/SageMaker to survive reboot
export PIPX_HOME=~/SageMaker/.initsmnb.d/pipx
export PIPX_BIN_DIR=~/SageMaker/.initsmnb.d/bin
cat << EOF >> ~/.bashrc
export PATH=\$PATH:$PIPX_BIN_DIR
export PIPX_HOME=$PIPX_HOME
EOF

# Stop 'pipx install' from warning about path
export PATH=$PATH:$PIPX_BIN_DIR

declare -a PKG=(
    pre-commit
    ranger-fm
    cookiecutter
    jupytext
    s4cmd
)

for i in "${PKG[@]}"; do
    ~/anaconda3/bin/pipx install $i
done

# pre-commit cache survives reboot (NOTE: can also set $PRE_COMMIT_HOME)
mkdir -p ~/SageMaker/.initsmnb.d/.pre-commit.cache
ln -s ~/SageMaker/.initsmnb.d/.pre-commit.cache ~/.cache/pre-commit

# ranger defaults to relative line number
mkdir -p ~/.config/ranger/
echo set line_numbers relative >> ~/.config/ranger/rc.conf
