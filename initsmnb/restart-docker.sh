#!/bin/bash

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR != "Amazon Linux 2" ]]; then
    echo ${BASH_SOURCE[0]} does not support alinux instance.
    exit 1
fi

sudo mkdir -p ~ec2-user/SageMaker/.initsmnb.d/tmp/

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl show --property=Environment docker

# Allow ec2-user access to the new tmp (which belongs to ec2-user anyway).
sudo chmod 777 ~ec2-user/SageMaker/.initsmnb.d/tmp/
sudo rm -fr ~ec2-user/SageMaker/.initsmnb.d/tmp/*
