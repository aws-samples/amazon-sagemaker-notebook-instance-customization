#!/bin/bash
JUPYTER_CONFIG_ROOT=~/.jupyter/lab/user-settings/\@jupyterlab

echo "After this script finishes, reload the Jupyter-Lab page in your browser."

mkdir -p $JUPYTER_CONFIG_ROOT/apputils-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/apputils-extension/themes.jupyterlab-settings
{
    // Theme
    // @jupyterlab/apputils-extension:themes
    // Theme manager settings.
    // *************************************

    // Theme CSS Overrides
    // Override theme CSS variables by setting key-value pairs here
    "overrides": {
        "code-font-size": "11px",
        "content-font-size1": "13px"
    }
}
EOF

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

    // Theme
    // The theme for the terminal.
    "theme": "dark"
}
EOF

mkdir -p $JUPYTER_CONFIG_ROOT/fileeditor-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/fileeditor-extension/plugin.jupyterlab-settings
{
    "editorConfig": {
        "rulers": [80, 100],
        "codeFolding": true,
        "lineNumbers": true
    }
}
EOF

mkdir -p $JUPYTER_CONFIG_ROOT/notebook-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/notebook-extension/tracker.jupyterlab-settings
{
    "codeCellConfig": {
        "rulers": [80, 100],
        "lineNumbers": true
    },
    "markdownCellConfig": {
        "rulers": [80, 100],
        "lineNumbers": true
    },
    "rawCellConfig": {
        "rulers": [80, 100],
        "lineNumbers": true
    }
}
EOF
