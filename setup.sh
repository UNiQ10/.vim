#!/bin/sh

# Check if curl exists.
CURL_FOUND=1

curl --help > /dev/null 2>&1
if [ $? -ne 0 ]; then
    CURL_FOUND=0
    exit 1
fi

# Find the directory path of setup.sh.
DIR="$( cd -- "$( dirname -- "$0" )" > /dev/null && pwd )"

# vim setup
echo "Creating symlink to $DIR/.vimrc at $HOME/.vimrc."

if [ -f "$HOME"/.vimrc ]; then
    echo ".vimrc already exists at $HOME! Press y when prompted to remove it."
    rm -i "$HOME"/.vimrc
    if [ -f "$HOME"/.vimrc ]; then
        echo "Failed to create symlink at $HOME/.vimrc! Exiting."
        exit 1
    fi
fi

ln -s -- "$DIR"/.vimrc "$HOME"/.vimrc

echo ".vimrc symlink created."

# Try downloading vim-plug and do not exit automatically anymore.
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
