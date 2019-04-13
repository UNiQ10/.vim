#!/bin/sh

# Check if curl exists.
CURL_FOUND=1

curl --help > /dev/null 2>&1
if [ $? -ne 0 ]; then
    CURL_FOUND=0
fi

# Automatically exit if any of the subsequent command fails.
# NOTE: This option will be disabled further down in the script.
set -e

# Find the directory path of setup.sh.
DIR="$( cd -- "$( dirname -- "$0" )" > /dev/null 2>&1 && pwd )"
CONFIG_BACKUP_DIR="$DIR/config_backups"

# vim setup
echo "Creating symlink to $DIR/.vimrc at $HOME/.vimrc."

if [ -e "$HOME"/.vimrc ]; then
    echo ".vimrc already exists at $HOME!"
    echo "Backing it up to $CONFIG_BACKUP_DIR."
    mv -- "$HOME"/.vimrc "$CONFIG_BACKUP_DIR"
fi

ln -fs -- "$DIR"/.vimrc "$HOME"/.vimrc

echo ".vimrc symlink created."


if [ -e "$HOME"/.vim -a "$HOME"/.vim = "$DIR" ]; then
    echo "$HOME/.vim same as script directory."
    echo ".vim symlink not required."
else
    if [ -e "$HOME"/.vim ]; then
        echo "A different .vim already exists at $HOME!"
        echo "Backing it up to $CONFIG_BACKUP_DIR"
        mv -- "$HOME"/.vim "$CONFIG_BACKUP_DIR"
    fi
    echo "Creating symlink to $DIR at $HOME/.vim."
    ln -fs -- "$DIR" "$HOME"/.vim
    echo ".vim symlink created."
fi

# nvim setup
NVIM_DIR="$HOME"/.config/nvim

if [ ! -z "$XDG_CONFIG_HOME" ]; then
    NVIM_DIR="$XDG_CONFIG_HOME"/nvim
fi

if [ -e "$NVIM_DIR" ]; then
    echo "nvim config directory already exists at $NVIM_DIR!"
    echo "Backing it up to $CONFIG_BACKUP_DIR."
    mv -- "$NVIM_DIR" "$CONFIG_BACKUP_DIR"
fi

ln -fs -- "$DIR"/nvim "$NVIM_DIR"

echo "nvim directory symlink created."
echo "Vim configuration completed."

# Do not exit automatically on command failure anymore.
set +e

# Try installing python3 neovim package for deoplete autocompletion support.
echo "Attempting to install python3 neovim package."

pip3  install --user --upgrade neovim

if [ $? -ne 0 ]; then
    echo "Python3 neovim package installation failed!"
    echo "Might need manual installation for deoplete autocompletion support."
fi

# Try downloading vim-plug.
if [ $CURL_FOUND -eq 1 ]; then
    echo "Downloading vim-plug plugin manger to autoload directory."
    curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
        --create-dirs -Lo "$DIR"/autoload/plug.vim

    if [ $? -ne 0 ]; then
        echo "vim-plug download failed!."
        echo "Install vim-plug and the plugins manually."
    else
        echo "vim-plug download completed."
        echo "Attempting to install plugins."
        vim +PlugUpdate +qall
        if [ $? -ne 0 ]; then
            echo "Automatic plugin installation failed!"
            echo "Open Vim and execute ':PlugUpdate' for manual installation."
        else
            echo "Plugins installed."
        fi
    fi
else
    echo "Curl not found. Cannot download vim-plug!"
    echo "Install vim-plug and the plugins manually."
fi
