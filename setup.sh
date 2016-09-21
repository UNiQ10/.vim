#!/bin/bash

# Create a symlink for $HOME/.vimrc.
# Will prompt to delete existing .vimrc.

# Find the directory path of setup.sh.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -e "$HOME""/.vimrc" ]]; then
    echo "A .vimrc already exists! Press y when prompted to remove it."
    rm -i "$HOME""/.vimrc"
    if [[ -e "$HOME""/.vimrc" ]]; then
        echo "Failed to setup .vimrc! Exiting."
        exit 1
    fi
fi

ln -s "$DIR""/.vimrc" "$HOME""/.vimrc"

echo ".vimrc setup completed! Done."
