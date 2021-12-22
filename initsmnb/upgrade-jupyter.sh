#!/bin/bash

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR != "Amazon Linux 2" ]]; then
    echo ${BASH_SOURCE[0]} does not support alinux instance.
    exit 1
fi

################################################################################
# IMPLEMENTATION NOTES: upgrade in-place JupyterSystemEnv instead of createing a
# new conda env for the new Jupyter version, because the original conda
# environment has sagemaker nbi agents installed (and possibly other pypi stuffs
# needed to make notebook instance works).
################################################################################

CONDA_ENV_DIR=~/anaconda3/envs/JupyterSystemEnv/
BIN_DIR=$CONDA_ENV_DIR/bin

# Uninstall the old jupyter proxy
$BIN_DIR/jupyter serverextension disable --py nbserverproxy
sed -i \
    's/"nbserverproxy": true/"nbserverproxy": false/g' \
    $CONDA_ENV_DIR/etc/jupyter/jupyter_notebook_config.json
$BIN_DIR/pip uninstall --yes nbserverproxy

# Upgrade jlab & extensions
declare -a PKGS=(
    notebook
    jupyterlab
    jupyter_bokeh
    jupyter-server-proxy
    nbdime

    # jupyterlab_code_formatter requires formatters in its venv.
    # See: https://github.com/ryantam626/jupyterlab_code_formatter/issues/153
    jupyterlab_code_formatter
    black
    isort
)
$BIN_DIR/pip install --no-cache-dir --upgrade "${PKGS[@]}"

# These are outdated by Jlab-3.x which has built-in versions of them.
for i in $CONDA_ENV_DIR/share/jupyter/lab/extensions/jupyterlab-{celltags,toc,git}-*.tgz; do
    rm $i
done
