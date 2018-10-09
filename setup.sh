#!/bin/sh

# Check if curl exists.
CURL_FOUND=1

curl --help > /dev/null 2>&1
if [ $? -ne 0 ]; then
    CURL_FOUND=0
    exit 1
fi

# Automatically exit if any of the subsequent command fails.
set -e

# Find the directory path of setup.sh.
DIR="$( cd -- "$( dirname -- "$0" )" > /dev/null && pwd )"
CONFIG_BACKUP_DIR="$DIR/config_backups"

# vim setup
echo "Creating symlink to $DIR/.vimrc at $HOME/.vimrc."

if [ -e "$HOME"/.vimrc ]; then
    echo ".vimrc already exists at $HOME!"
    echo "Backing it up to $CONFIG_BACKUP_DIR."
    mv -- "$HOME"/.vimrc "$CONFIG_BACKUP_DIR"
fi

ln -s -- "$DIR"/.vimrc "$HOME"/.vimrc

echo ".vimrc symlink created."

# Try downloading vim-plug and do not exit automatically anymore.
set +e
if [ $CURL_FOUND -eq 1 ]; then
    echo "Downloading vim-plug plugin manger to autoload directory."
    curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
        --create-dirs -Lo "$DIR"/autoload/plug.vim

    if [ $? -ne 0 ]; then
        echo "vim-plug download failed!."
        echo "Install vim-plug and the plugins manually."
    else
        echo "vim-plug download completed."
        echo "Run Vim and execute ':PlugUpdate' to install plugins."
    fi
else
    echo "Curl not found. Cannot download vim-plug!"
    echo "Install vim-plug and the plugins manually."
fi

echo "Vim configuration completed."
