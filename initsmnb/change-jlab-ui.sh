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
    },

    // Scrollbar Theming
    // Enable/disable styling of the application scrollbars
    "theme-scrollbars": false
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

mkdir -p $JUPYTER_CONFIG_ROOT/codemirror-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/codemirror-extension/plugin.jupyterlab-settings
{
    // CodeMirror
    // @jupyterlab/codemirror-extension:plugin
    // Text editor settings for all CodeMirror editors.
    // ************************************************

    "defaultConfig": {
        "codeFolding": true,
        "highlightActiveLine": true,
        "highlightTrailingWhitespace": true,
        "rulers": [
            80,
            100
        ]
    }
}
EOF

mkdir -p $JUPYTER_CONFIG_ROOT/notebook-extension/
cat << EOF > $JUPYTER_CONFIG_ROOT/notebook-extension/tracker.jupyterlab-settings
{
    // Notebook
    // @jupyterlab/notebook-extension:tracker
    // Notebook settings.
    // **************************************

    // Code Cell Configuration
    // The configuration for all code cells; it will override the CodeMirror default configuration.
    "codeCellConfig": {
        "lineNumbers": true,
        "lineWrap": true
    },

    // Markdown Cell Configuration
    // The configuration for all markdown cells; it will override the CodeMirror default configuration.
    "markdownCellConfig": {
        "lineNumbers": true,
        "lineWrap": true
    },

    // Raw Cell Configuration
    // The configuration for all raw cells; it will override the CodeMirror default configuration.
    "rawCellConfig": {
        "lineNumbers": true,
        "lineWrap": true
    }
}
EOF
