#!/bin/bash


GIT_VERSION=$(git --version)
if [[ "$GIT_VERSION" < "git version 2.28" ]]; then
    GIT_MSG=$(cat << EOF
The git version on this SageMaker classic notebook instance is older than 2.28,
hence `git init` will default to branch 'master'.

To initialize a new, empty git repo with branch 'main' as the default, run:

    $ git init; git checkout -b main
EOF
    echo -i "$GIT_MSG"
