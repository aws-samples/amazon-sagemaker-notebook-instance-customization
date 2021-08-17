#!/bin/bash

echo "Generating ~/.inputrc to fix a few bash shortcuts when browser runs on OSX..."
cat << EOF >> /home/ec2-user/.inputrc
# A few bash shortcuts when browser runs on OSX
"ƒ": forward-word
"∫": backward-word
"≥": yank-last-arg
"∂": kill-word
EOF

echo "Enabling keymap in ~/.bash_profile ..."
cat << EOF >> /home/ec2-user/.bash_profile

# Fix a few bash shortcuts when browser runs on OSX
bind -f /home/ec2-user/.inputrc
EOF

echo "Keymap set to deal with OSX quirks."
echo "To manually enforce keymap: bind -f ~/.inputrc"
