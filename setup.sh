#!/bin/bash

# Find the directory path of setup.sh.
DIR="$( dirname "$(readlink -f "$0" )")"

# Create a symlink to $DIR/.vimrc at $HOME/.vimrc.
# Will prompt to delete existing .vimrc.
echo "Creating symlink to $DIR/.vimrc at $HOME/.vimrc."

if [ -f "$HOME"/.vimrc ]; then
    echo ".vimrc already exists at $HOME! Press y when prompted to remove it."
    rm -i "$HOME"/.vimrc
    if [ -f "$HOME"/.vimrc ]; then
        echo "Failed to create symlink at $HOME/.vimrc! Exiting."
        exit 1
    fi
fi

ln -s "$DIR"/.vimrc "$HOME"/.vimrc

echo ".vimrc symlink created."

# Dowload plug.vim plugin manager to autoload directory.
echo "Downloading vim-plug plugin manger to autoload directory."

curl -fLo "$DIR"/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ $? -ne 0 ]; then
    echo "vim-plug download failed! Exiting."
    exit 1
fi

echo "vim-plug download completed."

# Setup complete.
echo "Vim configuration completed."
echo "Run Vim and execute ':PlugUpdate' to install plugins."
