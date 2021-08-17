"""Setup keybindings on ipython is started from JupyterLab terminal.
See:
- ipython keybindings: https://ipython.readthedocs.io/en/stable/config/details.html#keyboard-shortcuts
- Named shortcuts: https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/prompt_toolkit/key_binding/bindings/named_commands.py
"""

from IPython import get_ipython
from prompt_toolkit.enums import DEFAULT_BUFFER
from prompt_toolkit.filters import HasFocus, HasSelection
from prompt_toolkit.key_binding.bindings.named_commands import get_by_name

ip = get_ipython()

# Register the shortcut if IPython is using prompt_toolkit.
if getattr(ip, 'pt_app', None):
    registry = ip.pt_app.key_bindings

    # OSX: option-f
    registry.add_binding(
            "ƒ",
            #filter=(HasFocus(DEFAULT_BUFFER) & ~HasSelection())
            filter=HasFocus(DEFAULT_BUFFER)
    )(get_by_name('forward-word'))

    # OSX: option-b
    registry.add_binding(
            "∫",
            #filter=(HasFocus(DEFAULT_BUFFER) & ~HasSelection())
            filter=HasFocus(DEFAULT_BUFFER)
    )(get_by_name('backward-word'))

    # OSX: option-b
    registry.add_binding(
            "∂",
            #filter=(HasFocus(DEFAULT_BUFFER) & ~HasSelection())
            filter=HasFocus(DEFAULT_BUFFER)
    )(get_by_name('kill-word'))

    # OSX: option-.
    registry.add_binding(
            "≥",
            #filter=(HasFocus(DEFAULT_BUFFER) & ~HasSelection())
            filter=HasFocus(DEFAULT_BUFFER)
    )(get_by_name('yank-last-arg'))
