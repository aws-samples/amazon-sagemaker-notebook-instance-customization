#!/bin/bash

# JLab-3.x version since early Jul'22 switches certain config to jupyter_server_config.py.
# See: https://jupyter-server.readthedocs.io/en/stable/operators/migrate-from-nbserver.html
#
# To support both alinux2-jlab-{1,3}, duplicate the affected configs on both config files.
# Rule-of-thump: c.NotebookApp.* (in *config*.py) => c.ServerApp.* (in *server*.py).

try_append() {
    local key="$1"
    local value="$2"
    local msg="$3"
    local cfg="$4"

    HAS_KEY=$(grep "^$key" ~/.jupyter/jupyter_${cfg}_config.py | wc -l)

    if [[ $HAS_KEY > 0 ]]; then
        echo "Skip adding $key because it already exists in $HOME/.jupyter/jupyter_${cfg}_config.py"
        return 1
    fi

    echo "$key = $value" >> ~/.jupyter/jupyter_${cfg}_config.py
    echo $msg
}

touch ~/.jupyter/jupyter_server_config.py

try_append \
    c.NotebookApp.terminado_settings \
    "{'shell_command': ['/bin/bash', '-l']}" \
    "Changed shell to /bin/bash" \
    notebook

try_append \
    c.ServerApp.terminado_settings \
    "{'shell_command': ['/bin/bash', '-l']}" \
    "Changed shell to /bin/bash" \
    server

try_append \
    c.EnvironmentKernelSpecManager.conda_env_dirs \
    "['/home/ec2-user/anaconda3/envs', '/home/ec2-user/SageMaker/envs']" \
    "Register additional prefixes for conda environments" \
    notebook

try_append \
    c.EnvironmentKernelSpecManager.conda_env_dirs \
    "['/home/ec2-user/anaconda3/envs', '/home/ec2-user/SageMaker/envs']" \
    "Register additional prefixes for conda environments" \
    server

echo 'To enforce the change to jupyter config: sudo initctl restart jupyter-server --no-wait'
echo 'then refresh your browser'
