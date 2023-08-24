#!/bin/bash

set -euo pipefail

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

# Completely remove these unused or outdated Python packages.
$BIN_DIR/pip uninstall --yes jupyterlab-git

# These will be outdated by Jlab-3.x which has built-in versions of them.
declare -a EXTS_TO_DEL=(
    jupyterlab-celltags
    jupyterlab-toc
    jupyterlab-git
    nbdime-jupyterlab
)2
for i in "${EXTS_TO_DEL[@]}"; do
    rm $CONDA_ENV_DIR/share/jupyter/lab/extensions/$i-*.tgz || true
done

# Do whatever it takes to prevent JLab pop-up "Build recommended..."
$BIN_DIR/jupyter lab clean
cp $CONDA_ENV_DIR/share/jupyter/lab/static/package.json{,.ori}
cat $CONDA_ENV_DIR/share/jupyter/lab/static/package.json.ori \
  | jq 'del(.dependencies."@jupyterlab/git", .jupyterlab.extensions."@jupyterlab/git", .jupyterlab.extensionMetadata."@jupyterlab/git")' \
  > $CONDA_ENV_DIR/share/jupyter/lab/static/package.json

# Also silence JLab pop-up "Build recommended..." due to SageMaker extensions (examples and session agent).
cat << 'EOF' > ~/.jupyter/jupyter_server_config.json
{
  "LabApp": {
    "tornado_settings": {
      "page_config_data": {
        "buildCheck": false,
        "buildAvailable": false
      }
    }
  }
}
EOF

# Upgrade jlab & extensions
declare -a PKGS=(
    ipython
    notebook
    "nbclassic!=0.4.0"   # https://github.com/jupyter/nbclassic/issues/121
    ipykernel
    jupyterlab
    jupyter-server-proxy
    "environment_kernels>=1.2.0"  # https://github.com/Cadair/jupyter_environment_kernels/releases/tag/v1.2.0

    jupyter
    jupyter_client
    jupyter_console
    jupyter_core

    jupyter_bokeh

    # https://github.com/jupyter/nbdime/issues/621
    nbdime
    ipython_genutils

    jupyterlab-execute-time
    jupyterlab-skip-traceback
    jupyterlab-unfold
    stickyland

    # jupyterlab_code_formatter requires formatters in its venv.
    # See: https://github.com/ryantam626/jupyterlab_code_formatter/issues/153
    #
    # [20230401] v1.6.0 is broken on python<=3.8
    # See: https://github.com/ryantam626/jupyterlab_code_formatter/issues/193#issuecomment-1488742233
    "jupyterlab_code_formatter!=1.6.0"
    black
    isort
)
# Overwrite above definition of PKGS to exclude jlab packages. This is done to reduce update time
# (because sagemaker alinux2 is pretty up-to-date. Usually 1-2 patch versions away only).
# To still update jlab packages, comment the PKGS definition below.
declare -a PKGS=(
    "environment_kernels>=1.2.0"  # https://github.com/Cadair/jupyter_environment_kernels/releases/tag/v1.2.0
    jupyter_bokeh
    jupyterlab-execute-time
    jupyterlab-skip-traceback
    jupyterlab-unfold
    stickyland
    ipython_genutils  # https://github.com/jupyter/nbdime/issues/621

    # jupyterlab_code_formatter requires formatters in its venv.
    # See: https://github.com/ryantam626/jupyterlab_code_formatter/issues/153
    #
    # [20230401] v1.6.0 is broken on python<=3.8
    # See: https://github.com/ryantam626/jupyterlab_code_formatter/issues/193#issuecomment-1488742233
    "jupyterlab_code_formatter!=1.6.0"
    black
    isort
)
$BIN_DIR/pip install --no-cache-dir --upgrade pip  # Let us welcome colorful pip.
$BIN_DIR/pip install --no-cache-dir --upgrade "${PKGS[@]}"


################################################################################
# STEP-01: Start-up settings
################################################################################
# No JupyterSystemEnv's "Python3 (ipykernel)", same as stock notebook instance
[[ -f ~/anaconda3/envs/JupyterSystemEnv/share/jupyter/kernels/python3/kernel.json ]] \
    && rm ~/anaconda3/envs/JupyterSystemEnv/share/jupyter/kernels/python3/kernel.json

# File operations
for i in ~/.jupyter/jupyter_{notebook,server}_config.py; do
    echo "c.FileContentsManager.delete_to_trash = False" >> $i
    echo "c.FileContentsManager.always_delete_dir = True" >> $i
done


################################################################################
# STEP-02: Apply jlab-3+ UI configs
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
rm ~/.ipython/profile_default/startup/01-osx-jupyterlab-keys.py || true

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

# Default to the advanced json editor to edit the settings.
# Since v3.4.x; https://github.com/jupyterlab/jupyterlab/pull/12466
mkdir -p $JUPYTER_CONFIG_ROOT/settingeditor-extension
cat << EOF > $JUPYTER_CONFIG_ROOT/settingeditor-extension/form-ui.jupyterlab-settings
{
    // Settings Editor Form UI
    // @jupyterlab/settingeditor-extension:form-ui
    // Settings editor form ui settings.
    // *******************************************

    // Type of editor for the setting.
    // Set the type of editor to use while editing your settings.
    "settingEditorType": "json"
}
EOF

# Disable notification -- Jlab started to get extremely noisy since v3.6.0+
mkdir -p $JUPYTER_CONFIG_ROOT/settingeditor-extension
cat << 'EOF' > $JUPYTER_CONFIG_ROOT/apputils-extension/notification.jupyterlab-settings
{
    // Notifications
    // @jupyterlab/apputils-extension:notification
    // Notifications settings.
    // *******************************************

    // Check for JupyterLab updates
    // Whether to check for newer version of JupyterLab or not. It requires `fetchNews` to be `true`
    // to be active. If `true`, it will make a request to a website.
    "checkForUpdates": false,

    // Silence all notifications
    // If `true`, no toast notifications will be automatically displayed.
    "doNotDisturbMode": true,

    // Fetch official Jupyter news
    // Whether to fetch news from Jupyter news feed. If `true`, it will make a request to a website.
    "fetchNews": "false"
}
EOF
