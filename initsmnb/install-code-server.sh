#!/bin/bash

install_code_server() {
    mkdir -p ~/.local/share/ ~/SageMaker/.initsmnb.d/.local/share/code-server/
    [[ -d ~/.local/share/code-server ]] \
        || ln -s ~/SageMaker/.initsmnb.d/.local/share/code-server ~/.local/share/code-server

    curl -fsSL https://code-server.dev/install.sh | sh
    rm -fr ~/.cache/code-server/
}

install_ext() {
    # [20221023] https://github.com/verdimrc/linuxcfg/blob/main/vscode/extensions.json
    #
    # Code-server cannot install some extensions, which is expected.
    # See: https://github.com/coder/code-server/discussions/2345.
    declare -a EXT=(
        "adpyke.vscode-sql-formatter"
        "bierner.markdown-mermaid"
        "bungcip.better-toml"
        "christian-kohler.path-intellisense"
        "DavidAnson.vscode-markdownlint"
        "donjayamanne.githistory"
        "donjayamanne.python-environment-manager"
        "EditorConfig.EditorConfig"
        "emilast.LogFileHighlighter"
        "Gruntfuggly.todo-tree"
        "IBM.output-colorizer"
        "leonhard-s.python-sphinx-highlight"
        "mechatroner.rainbow-csv"
        "mhutchie.git-graph"
        "mikestead.dotenv"
        "ms-python.black-formatter"
        "ms-python.isort"
        "ms-python.python"
        "ms-toolsai.vscode-jupyter-powertoys"
        "ms-vscode.live-server"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode-remote.remote-ssh-edit"
        "njpwerner.autodocstring"
        "redhat.vscode-yaml"
        "shardulm94.trailing-spaces"
        "stkb.rewrap"
        "tomoki1207.pdf"
        "usernamehw.errorlens"
        "VisualStudioExptTeam.vscodeintellicode"
        "yzhang.markdown-all-in-one"
    )
    for i in "${EXT[@]}"; do
        code-server --install-extension $i
    done
}

apply_setting() {
    # [20221023] https://github.com/verdimrc/linuxcfg/blob/main/vscode/keybindings.json
    cat << 'EOF' > ~/.local/share/code-server/User/keybindings.json
// Place your key bindings in this file to override the defaults
[
    // Since vscode-1.44, OSX + iTerm2 needs this new setting to pass
    // alt-backspace correctly to bash.
    {
        "key": "alt+backspace",
        "command": "deleteWordPartLeft",
        "when": "terminalFocus && isMac"
    },
    // Re-assign ctrl-f in terminal, to remove conflict with vim (Linux)
    {
        "key": "ctrl+shift+f",
        "command": "workbench.action.terminal.focusFind",
        "when": "terminalFindFocused || terminalFocus"
    },
    {
        "key": "ctrl+f",
        "command": "-workbench.action.terminal.focusFind",
        "when": "terminalFindFocused || terminalFocus"
    },

    // Remove alt-w (Linux), since my zsh remaps alt-w to backward-kill-dir
    // TODO: figure out the correct "when", rather then disable at all.
    {
        "key": "alt+w",
        "command": "-workbench.action.terminal.toggleFindWholeWord"
    }
]
EOF

    # [20221023] https://github.com/verdimrc/linuxcfg/blob/main/vscode/settings.json
    #
    # Notable changes:
    # - "python.languageServer" from "Pylance" to "Jedi" (https://github.com/coder/code-server/issues/1938)
    cat << 'EOF' > ~/.local/share/code-server/User/settings.json
{
    ///////////////////////////////////////////////////////////////////////////
    // initsmnb specific
    ///////////////////////////////////////////////////////////////////////////
    "workbench.colorTheme": "Default Dark+",
    "terminal.integrated.shell.linux": "/bin/bash",


    ///////////////////////////////////////////////////////////////////////////
    // OFF TELEMETRIES (LIFTED TO NEAR TOP FOR VISIBILITY
    ///////////////////////////////////////////////////////////////////////////

    // Global telemetries
    "telemetry.enableCrashReporter": false, // Deprecated since v1.61 Oct'21
    "telemetry.enableTelemetry": false, // Deprecated since v1.61 Oct'21
    "telemetry.telemetryLevel": "off", // Since v1.61 Oct'21
    "python.experiments.enabled": false,
    "workbench.enableExperiments": false,

    // Extensions telemetries
    "aws.telemetry": false,
    "gitlens.advanced.telemetry.enabled": false,
    "redhat.telemetry.enabled": false,


    ///////////////////////////////////////////////////////////////////////////
    // EXPERIMENTAL OR PREVIEW FEATURES
    ///////////////////////////////////////////////////////////////////////////
    "markdown.experimental.updateLinksOnFileMove.enabled": "always", // aug22


    ///////////////////////////////////////////////////////////////////////////
    // HYPER-PERSONALIZED STANZA
    ///////////////////////////////////////////////////////////////////////////

    // Python paths.
    // NOTE: if you change "python.defaultInterpreterPath", then on code-server UI:
    // 1. press ctrl+shift+p
    // 2. type or select "Jupyter: Select Interpreter to Start Jupyter Server", then press Enter
    // 3. choose "Python 3.x.x ('JupyterSystemEnv') ~/anaconda3/envs/JupyterSystemEnv/bin/python"
    "python.defaultInterpreterPath": "/home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/python",

    "terminal.integrated.env.osx": {
        "PYTHONPATH": "${workspaceFolder}/src:${env:PYTHONPATH}"
    },
    "terminal.integrated.env.linux": {
        "PYTHONPATH": "${workspaceFolder}/src:${env:PYTHONPATH}"
    },

    // To use binaries outside of selected python interpreter, e.g., those installed by pipx
    //"python.linting.flake8Path": "/usr/local/bin/flake8",
    //"python.linting.mypyPath": "/usr/local/bin/mypy",
    //"python.linting.pydocstylePath": "/home/verdi/.local/bin/pydocstyle",

    // GUI: vscode
    "window.zoomLevel": 0,
    //"editor.fontFamily": "Monego",
    "debug.console.fontSize": 11,
    "editor.fontSize": 11,
    //"editor.lineHeight": 18,
    "terminal.integrated.fontSize": 11,
    "extensions.ignoreRecommendations": true, // Default to true; set false if you prefer.
    "workbench.colorCustomizations": {
        "editor.lineHighlightBackground": "#2d2d2d" // For dark theme
    },
    // "window.titleBarStyle": "custom",
    // GUI: extensions
    "markdown.preview.fontSize": 16, // yzhang.markdown-all-in-one


    ///////////////////////////////////////////////////////////////////////////
    // OTHER CONFIGS
    ///////////////////////////////////////////////////////////////////////////

    // File exclusions
    "files.exclude": {
        "**/.git": true,
        "**/.svn": true,
        "**/.hg": true,
        "**/CVS": true,
        "**/.DS_Store": true,
        "**/._*": true,
        "**/__pycache__": true,
        "**/.ipynb_checkpoints": true,
        "**/.*_cache": true,
        "**/.tox": true
    },
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/*/**": true,
        "**/._*/**": true,
        "**/__pycache__/**": true,
        "**/.ipynb_checkpoints/**": true,
        "**/.*_cache/**": true,
        "**/.tox/**": true
    },

    "files.associations": {
        "Dockerfile.cpu": "dockerfile",
        "Dockerfile.gpu": "dockerfile"
    },

    // Javascript
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.pettier-vscode",
        "editor.codeActionsOnSave": {
            // "source.fixAll.eslint": false,
            "source.fixAll": false  // Don't like. Too aggressive during dev.
        }
    },

    // Python
    "debug.allowBreakpointsEverywhere": true,
    "jupyter.askForKernelRestart": false,
    "jupyter.debugJustMyCode": false,
    "jupyter.disableJupyterAutoStart": true,
    "jupyter.magicCommandsAsComments": true,
    "jupyter.sendSelectionToInteractiveWindow": true,
    "notebook.lineNumbers": "on",
    "python.formatting.provider": "black",
    "[python]": {
        "editor.defaultFormatter": "ms-python.black-formatter",
        "editor.codeActionsOnSave": {
            "source.fixAll": false // Don't like. Import can be removed unpredictably.
        }
    },
    "python.analysis.inlayHints.variableTypes": true,
    "python.analysis.inlayHints.functionReturnTypes": true,
    "python.languageServer": "Jedi",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "python.linting.mypyArgs": [ "--show-error-codes" ],
    "python.linting.pydocstyleEnabled": false,
    "python.showStartPage": false,
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,

    // Workbench & editor
    "breadcrumbs.enabled": true,
    "editor.bracketPairColorization.enabled": true,
    "editor.formatOnSave": true,
    //"editor.formatOnSaveMode": "modifications",  //Not supported with Black
    "editor.codeActionsOnSave": {
        "source.fixAll.markdownlint": true, // Extension davidanson.vscode-markdownlint
        "source.organizeImports": true
    },
    "editor.minimap.enabled": false,
    "editor.parameterHints.cycle": true,
    "editor.renderLineHighlight": "all",
    //"editor.renderWhitespace": "trailing",
    "editor.renderControlCharacters": false,
    "editor.rulers": [
        80,
        100
    ],
    "editor.stickyScroll.enabled": true,
    "editor.stickyTabStops": true,
    "editor.suggestSelection": "first",
    "editor.wordWrapColumn": 100,
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "explorer.openEditors.visible": 0,
    "files.eol": "\n",
    "git.terminalAuthentication": false,
    "scm.diffDecorationsGutterPattern": {
        "added": true
    },
    "json.format.keepLines": true,
    "outline.showVariables": false,
    "terminal.integrated.enableMultiLinePasteWarning": false,
    "terminal.integrated.lineHeight": 1.2,
    "terminal.integrated.localEchoLatencyThreshold": -1,
    "terminal.integrated.persistentSessionReviveProcess": "never",
    "terminal.integrated.enablePersistentSessions": false,
    "terminal.integrated.shellIntegration.enabled": true, // Jul22 default is on
    "workbench.editor.decorations.colors": true,
    "workbench.editor.decorations.badges": true,
    // "workbench.editor.enablePreviewFromCodeNavigation": true,
    "workbench.reduceMotion": "on",
    "workbench.startupEditor": "none",
    "workbench.tree.indent": 20,

    // Shortcuts in integrated terminal
    "terminal.integrated.allowChords": false, // send ctrl+k to integrated terminal
    "terminal.integrated.commandsToSkipShell": [
        // Linux: send ctrl+e to integrated terminal
        "-workbench.action.quickOpen",

        // alt-backspace to behave like in Bash
        "-workbench.action.terminal.deleteWordLeft"
    ],
    //"terminal.integrated.macOptionIsMeta": true, // Allow alt-{f,b,.} in integrated terminal. See https://github.com/Microsoft/vscode/issues/11314
    "terminal.integrated.sendKeybindingsToShell": true,
    "terminal.integrated.showExitAlert": false,

    // Extensions
    "autoDocstring.docstringFormat": "google",
    "aws.samcli.location": "/usr/local/bin/sam",
    "aws.profile": "default",
    "gitlens.hovers.currentLine.over": "line",
    // "markdown.extension.preview.autoShowPreviewToSide": true,
    "[markdown]": {
        "editor.defaultFormatter": "yzhang.markdown-all-in-one"
    },
    "remote.SSH.defaultExtensions": [
        "adpyke.vscode-sql-formatter",
        "bierner.markdown-mermaid",
        "bungcip.better-toml",
        "christian-kohler.path-intellisense",
        "davidanson.vscode-markdownlint",
        "donjayamanne.githistory",
        "donjayamanne.python-environment-manager",
        "editorconfig.editorconfig",
        //"eamodio.gitlens",
        "gruntfuggly.todo-tree",
        "mechatroner.rainbow-csv",
        "mhutchie.git-graph",
        "ms-python.black-formatter",
        "ms-python.isort",
        "ms-python.vscode-pylance",
        "ms-python.python",
        "ms-toolsai.jupyter",
        "ms-toolsai.vscode-jupyter-powertoys",
        "ms-vscode.live-server",
        "njpwerner.autodocstring",
        "redhat.vscode-yaml",
        "shardulm94.trailing-spaces",
        "stkb.rewrap",
        "tomoki1207.pdf",
        "visualstudioexptteam.vscodeintellicode",
        "yzhang.markdown-all-in-one"
    ],
    "rewrap.wrappingColumn": 100,
    "sql-formatter.uppercase": true,
    "todo-tree.general.tags": [
        "BUG",
        "HACK",
        "FIXME",
        "TODO",
        "XXX",
        "[ ]",
        "[x]"
    ],
    "todo-tree.highlights.customHighlight": {
        "TODO": {
            "foreground": "yellow"
        },
        "FIXME": {
            "foreground": "red"
        }
    },
    "todo-tree.highlights.defaultHighlight": {
        "opacity": 0,
        "fontStyle": "italic",
        "fontWeight": "bold"
    },
    "todo-tree.regex.regex": "(//|#|<!--|;|/\\*|^|^\\s*(-|\\d+.))\\s*($TAGS)",
    "todo-tree.tree.showScanModeButton": true,
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue"
}
EOF
}

show_usage() {
    local SMNB_NAME=$(cat /opt/ml/metadata/resource-metadata.json  | jq -r '.ResourceName')
    local SMNB_URL=$(cat /etc/opt/ml/sagemaker-notebook-instance-config.json \
         | jq -r '.notebook_uri' \
         | sed 's/[\\()]//g' \
         | sed "s/|${SMNB_NAME}\.notebook/.notebook/"
    )

    cat << EOF
################################################################################
# Steps to run Code Server (filename: ~/HOWTO-RUN-CODE-SERVER.txt)
################################################################################
1. Open the terminal and run:

       code-server --auth=none --disable-telemetry --disable-update-check

2. Then, open a new browser tab and go to:

       $SMNB_URL/proxy/8080/
################################################################################
EOF
}


install_code_server
if [[ ! -e ~/.local/share/code-server/_SUCCESS ]]; then
    cat << 'EOF'

##############################################################################
# Cannot find ~/local/share/code-server/_SUCCESS.                            #
#                                                                            #
# It seems like this is the first time ever the install-code-server.sh runs  #
# on this SageMaker notebook instance.                                       #
#                                                                            #
# As such, I'm going to install several code-server extensions related to    #
# Python data science to boost your development experience.                  #
#                                                                            #
# Please be patient, as this one-time install may take a few minutes.        #
#                                                                            #
# The next time you restart this SageMaker notebook instance, the extensions #
# will still be available, and you shouldn't see this message anymore.       #
##############################################################################

EOF

    install_ext
    apply_setting
    touch ~/.local/share/code-server/_SUCCESS
fi
rm -fr ~/.local/share/code-server/{CachedExtensionVSIXs,CachedExtensions}/
show_usage | tee ~/HOWTO-RUN-CODE-SERVER.txt
