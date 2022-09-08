#!/bin/bash

FLAVOR=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f 2)
if [[ $FLAVOR != "Amazon Linux 2" ]]; then
    echo ${BASH_SOURCE[0]} does not support alinux instance.
    exit 1
fi


################################################################################
# STEP-00: upgrade to JLab-3.x
#
# [IMPLEMENTATION NOTES] Upgrade in-place JupyterSystemEnv instead of a new
# dedicated conda env for the new JLab, because the existing conda environment
# has sagemaker nbi agents installed (and possibly other pypi stuffs needed to
# make notebook instance works).
################################################################################
CONDA_ENV_DIR=~/anaconda3/envs/JupyterSystemEnv/
BIN_DIR=$CONDA_ENV_DIR/bin

# Uninstall the old jupyter proxy, to unblock Streamlit.
$BIN_DIR/jupyter serverextension disable --py nbserverproxy
sed -i \
    's/"nbserverproxy": true/"nbserverproxy": false/g' \
    $CONDA_ENV_DIR/etc/jupyter/jupyter_notebook_config.json
$BIN_DIR/pip uninstall --yes nbserverproxy

# Completely remove these unused or outdated Python packages.
$BIN_DIR/pip uninstall --yes nbdime jupyterlab-git

# These will be outdated by Jlab-3.x which has built-in versions of them.
declare -a EXTS_TO_DEL=(
    jupyterlab-celltags
    jupyterlab-toc
    jupyterlab-git
    nbdime-jupyterlab

    sagemaker_examples  # Won't work on jlab-3.x anyway.
)
for i in "${EXTS_TO_DEL[@]}"; do
    rm $CONDA_ENV_DIR/share/jupyter/lab/extensions/$i-*.tgz
done

# Upgrade jlab & extensions
declare -a PKGS=(
    ipython
    notebook
    "nbclassic!=0.4.0"   # https://github.com/jupyter/nbclassic/issues/121
    ipykernel
    jupyterlab
    jupyter-server-proxy

    jupyter
    jupyter_client
    jupyter_console
    jupyter_core

    jupyter_bokeh
    nbdime
    jupyterlab-execute-time
    jupyterlab-skip-traceback

    # jupyterlab_code_formatter requires formatters in its venv.
    # See: https://github.com/ryantam626/jupyterlab_code_formatter/issues/153
    jupyterlab_code_formatter
    black
    isort
)
$BIN_DIR/pip install --no-cache-dir --upgrade pip  # Let us welcome colorful pip.
$BIN_DIR/pip install --no-cache-dir --upgrade "${PKGS[@]}"

# See https://github.com/Cadair/jupyter_environment_kernels/pull/41
$BIN_DIR/pip install --no-cache-dir --force 'git+https://github.com/verdimrc/jupyter_environment_kernels.git@master#egg=environment_kernels'


################################################################################
# STEP-01: Maintain same behavior as stock notebook instance
################################################################################
# No JupyterSystemEnv kernel "Python3 (ipykernel)"
[[ -f ~/anaconda3/envs/JupyterSystemEnv/share/jupyter/kernels/python3/kernel.json ]] \
    && rm ~/anaconda3/envs/JupyterSystemEnv/share/jupyter/kernels/python3/kernel.json

# No trash
echo "c.FileContentsManager.delete_to_trash = False" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.FileContentsManager.delete_to_trash = False" >> ~/.jupyter/jupyter_server_config.py


################################################################################
# STEP-02: Apply jlab-3+ configs
################################################################################
JUPYTER_CONFIG_ROOT=~/.jupyter/lab/user-settings/\@jupyterlab

# Show trailing space is brand-new since JLab-3.2.0
# See: https://jupyterlab.readthedocs.io/en/3.2.x/getting_started/changelog.html#id22
mkdir -p $JUPYTER_CONFIG_ROOT/notebook-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/notebook-extension/tracker.jupyterlab-settings
{
    // Notebook
    // @jupyterlab/notebook-extension:tracker
    // Notebook settings.
    // **************************************
    "codeCellConfig": {
        "rulers": [80, 100],
        "codeFolding": true,
        "lineNumbers": true,
        "lineWrap": "off",
        "showTrailingSpace": true,
        "wordWrapColumn": 100
    },
    "markdownCellConfig": {
        "rulers": [80, 100],
        "codeFolding": true,
        "lineNumbers": true,
        "lineWrap": "off",
        "showTrailingSpace": true,
        "wordWrapColumn": 100
    },
    "rawCellConfig": {
        "rulers": [80, 100],
        "lineNumbers": true,
        "lineWrap": "off",
        "showTrailingSpace": true,
        "wordWrapColumn": 100
    },

    // Since: jlab-2.0.0
    // Used by jupyterlab-execute-time to display cell execution time.
    "recordTiming": true
}
EOF

mkdir -p $JUPYTER_CONFIG_ROOT/fileeditor-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/fileeditor-extension/plugin.jupyterlab-settings
{
    // Text Editor
    // @jupyterlab/fileeditor-extension:plugin
    // Text editor settings.
    // ***************************************
    "editorConfig": {
        "rulers": [80, 100],
        "codeFolding": true,
        "lineNumbers": true,
        "lineWrap": "off",
        "showTrailingSpace": true,
        "wordWrapColumn": 100
    }
}
EOF

# macOptionIsMeta is brand-new since JLab-3.0.
# See: https://jupyterlab.readthedocs.io/en/3.0.x/getting_started/changelog.html#other
mkdir -p $JUPYTER_CONFIG_ROOT/terminal-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/terminal-extension/plugin.jupyterlab-settings
{
    // Terminal
    // @jupyterlab/terminal-extension:plugin
    // Terminal settings.
    // *************************************

    // Font size
    // The font size used to render text.
    "fontSize": 11,
    "lineHeight": 1.3,

    // Theme
    // The theme for the terminal.
    "theme": "dark",

    // Treat option as meta key on macOS (new in JLab-3.0)
    // Option key on macOS can be used as meta key. This enables to use shortcuts such as option + f
    // to move cursor forward one word
    "macOptionIsMeta": true
}
EOF

# Undo the old "mac-option-is-meta" mechanism designed for jlab<3.0.
echo "# JLab-3 + macOptionIsMeta deprecates fix-osx-keymap.sh" > ~/.inputrc
rm ~/.ipython/profile_default/startup/01-osx-jupyterlab-keys.py

# Show command palette on lhs navbar, similar behavior to smnb.
mkdir -p $JUPYTER_CONFIG_ROOT/apputils-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/apputils-extension/palette.jupyterlab-settings
{
    // Command Palette
    // @jupyterlab/apputils-extension:palette
    // Command palette settings.
    // **************************************

    // Modal Command Palette
    // Whether the command palette should be modal or in the left panel.
    "modal": false
}
EOF

# Linter for notebook editors and code editors. Do not autosave on notebook, because it's broken
# on multi-line '!some_command \'. Note that autosave doesn't work on text editor anyway.
mkdir -p $JUPYTER_CONFIG_ROOT/../\@ryantam626/jupyterlab_code_formatter/
cat << EOF > $JUPYTER_CONFIG_ROOT/../\@ryantam626/jupyterlab_code_formatter/settings.jupyterlab-settings
{
    // Jupyterlab Code Formatter
    // @ryantam626/jupyterlab_code_formatter:settings
    // Jupyterlab Code Formatter settings.
    // **********************************************

    // Black Config
    // Config to be passed into black's format_str function call.
    "black": {
        "line_length": 100
    },

    // Auto format config
    // Auto format code when save the notebook.
    "formatOnSave": false,

    // Isort Config
    // Config to be passed into isort's SortImports function call.
    "isort": {
        "multi_line_output": 3,
        "include_trailing_comma": true,
        "force_grid_wrap": 0,
        "use_parentheses": true,
        "line_length": 100
    }
}
EOF

# Since: jlab-3.1.0
# - Conforms to markdown standard that h1 is for title,and h2 is for sections
#   (numbers start from 1).
# - Do not auto-number headings in output cells.
mkdir -p $JUPYTER_CONFIG_ROOT/toc-extension
cat << EOF > $JUPYTER_CONFIG_ROOT/toc-extension/plugin.jupyterlab-settings
{
    // Table of Contents
    // @jupyterlab/toc-extension:plugin
    // Table of contents settings.
    // ********************************
    "includeOutput": false,
    "numberingH1": false
}
EOF

# Shortcuts to format notebooks or codes with black and isort.
mkdir -p $JUPYTER_CONFIG_ROOT/shortcuts-extension
cat << EOF > $JUPYTER_CONFIG_ROOT/shortcuts-extension/shortcuts.jupyterlab-settings
{
    // Keyboard Shortcuts
    // @jupyterlab/shortcuts-extension:shortcuts
    // Keyboard shortcut settings.
    // *****************************************

    "shortcuts": [
        {
            "command": "jupyterlab_code_formatter:black",
            "keys": [
                "Ctrl Shift B"
            ],
            "selector": ".jp-Notebook.jp-mod-editMode"
        },
        {
            "command": "jupyterlab_code_formatter:black",
            "keys": [
                "Ctrl Shift B"
            ],
            "selector": ".jp-CodeMirrorEditor"
        },
        {
            "command": "jupyterlab_code_formatter:isort",
            "keys": [
                "Ctrl Shift I"
            ],
            "selector": ".jp-Notebook.jp-mod-editMode"
        },
        {
            "command": "jupyterlab_code_formatter:isort",
            "keys": [
                "Ctrl Shift I"
            ],
            "selector": ".jp-CodeMirrorEditor"
        }
    ]
}
EOF
