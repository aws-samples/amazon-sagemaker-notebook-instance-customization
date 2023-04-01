#!/bin/bash

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR == "Amazon Linux 2" ]]; then
    sudo amazon-linux-extras install -y epel
    sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/cyqsimon/el-rust-pkgs/repo/epel-7/cyqsimon-el-rust-pkgs-epel-7.repo
    # Slow install; hence disabled by default
    #sudo yum update -y
    sudo yum install -y htop tree fio dstat dos2unix tig ncdu ripgrep bat git-delta inxi mediainfo git-lfs aria2
    echo "alias ncdu='ncdu --color dark'" >> ~/.bashrc
else
    sudo yum install -y htop tree dstat dos2unix tig
fi
sudo yum clean all

~/anaconda3/bin/nbdime config-git --enable --global
ln -s ~/anaconda3/bin/nb{diff,diff-web,dime,merge,merge-web,show} ~/.local/bin
ln -s ~/anaconda3/bin/git-nb* ~/.local/bin

# Pipx to install pre-commit. Otherwise, pre-commit is broken when installed
# with /usr/bin/pip3 (alinux), but we don't want to use ~/anaconda/bin/pip3
# either to minimize polluting its site packages.
~/anaconda3/bin/pip3 install --no-cache-dir pipx

# Relocate pipx packages to ~/SageMaker to survive reboot
export PIPX_HOME=~/SageMaker/.initsmnb.d/pipx
export PIPX_BIN_DIR=~/SageMaker/.initsmnb.d/bin
cat << EOF >> ~/.bashrc
# Add pipx binaries to PATH. In addition, add also ~/.local/bin so that its
# commands are usable by Jupyter kernels (notable example: docker-compose for
# SageMaker local mode).
export PATH=\$PATH:$PIPX_BIN_DIR:/home/ec2-user/.local/bin
export PIPX_HOME=$PIPX_HOME
export PIPX_BIN_DIR=$PIPX_BIN_DIR
EOF

# Stop 'pipx install' from warning about path
export PATH=$PATH:$PIPX_BIN_DIR

declare -a PKG=(
    pre-commit
    ranger-fm
    cookiecutter
    jupytext
    s4cmd
    nvitop
    gpustat
    awslogs
    ruff
    #black
    #nbqa
    #isort
    #pyupgrade
)

for i in "${PKG[@]}"; do
    ~/anaconda3/bin/pipx install $i
done
~/anaconda3/bin/pipx upgrade-all

# pre-commit cache survives reboot (NOTE: can also set $PRE_COMMIT_HOME)
mkdir -p ~/SageMaker/.initsmnb.d/.pre-commit.cache
ln -s ~/SageMaker/.initsmnb.d/.pre-commit.cache ~/.cache/pre-commit

# ranger defaults to relative line number
mkdir -p ~/.config/ranger/
echo set line_numbers relative >> ~/.config/ranger/rc.conf

# Catch-up with awscliv2 which has nearly weekly releases.
wget -O /tmp/awscli2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
cd /tmp && unzip -q /tmp/awscli2.zip
./install --update --install-dir ~/SageMaker/.initsmnb.d/aws-cli-v2 --bin-dir ~/SageMaker/.initsmnb.d/bin
sudo ln -s ~/SageMaker/.initsmnb.d/bin/aws /usr/local/bin/aws2
rm /tmp/awscli2.zip
rm -fr /tmp/aws/
# Borrow these settings from aws-samples hpc repo
aws configure set default.s3.max_concurrent_requests 100
aws configure set default.s3.max_queue_size 10000
aws configure set default.s3.multipart_threshold 64MB
aws configure set default.s3.multipart_chunksize 16MB
aws configure set default.cli_auto_prompt on-partial
