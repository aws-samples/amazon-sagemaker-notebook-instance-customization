#!/bin/bash

sudo yum install -y htop tree dstat dos2unix tig
~/anaconda3/bin/nbdime config-git --enable --global

# Pipx to install pre-commit. Otherwise, pre-commit is broken when installed
# with /usr/bin/pip3, but we don't want to use ~/anaconda/bin/pip3 either to
# minimize polluting its site packages.
~/anaconda3/bin/pip3 install --no-cache-dir pipx

# Stop 'pipx install' from warning about path
PATH=$PATH:~/.local/bin

declare -a PKG=(
    pre-commit
    ranger-fm
    cookiecutter
    jupytext
)
for i in "${PKG[@]}"; do
    ~/anaconda3/bin/pipx install $i
done

# pre-commit cache survives reboot (NOTE: can also set $PRE_COMMIT_HOME)
mkdir -p ~/SageMaker/.pre-commit.cache
ln -s ~/SageMaker/.pre-commit.cache ~/.cache/pre-commit

# ranger defaults to relative line number
mkdir -p /home/ec2-user/.config/ranger/
echo set line_numbers relative >> /home/ec2-user/.config/ranger/rc.conf
