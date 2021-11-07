#!/bin/bash

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR != "Amazon Linux 2" ]]; then
    echo ${BASH_SOURCE[0]} does not support alinux instance.
    exit 1
fi

# Give docker build a bit more space. E.g., as of Nov'21, building a custom
# image based on the pytorch-1.10 DLC would fail due to exhausted /tmp.
sudo sed -i \
    's|^\[Service\]$|[Service]\nEnvironment="DOCKER_TMPDIR=/home/ec2-user/SageMaker/.initsmnb.d/tmp"|' \
    /usr/lib/systemd/system/docker.service
