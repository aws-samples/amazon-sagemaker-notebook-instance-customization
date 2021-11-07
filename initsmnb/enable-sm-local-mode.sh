#!/bin/bash

ln -s ~/anaconda3/bin/docker-compose ~/.local/bin/
curl -sfL \
    https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-local-mode/main/blog/pytorch_cnn_cifar10/setup.sh \
    | /bin/bash -s
