#!/bin/sh

safe_mv () {
    SRC_PATH="$1"
    DEST_DIR="$2"
    SRC_BASENAME="$( basename -- "$SRC_PATH" )"
    if [ ! -e "$DEST_DIR/$SRC_BASENAME" ]; then
        echo "Moving $SRC_PATH to $DEST_DIR/$SRC_BASENAME ."
        mv -- "$SRC_PATH" "$DEST_DIR/$SRC_BASENAME"
    else
        SUFFIX=1
        while [ -e "$DEST_DIR/$SRC_BASENAME""_$SUFFIX" ]; do
            SUFFIX=$(( $SUFFIX + 1 ))
        done
        echo "Moving $SRC_PATH to $DEST_DIR/$SRC_BASENAME""_$SUFFIX ."
        mv -- "$SRC_PATH" "$DEST_DIR/$SRC_BASENAME""_$SUFFIX"
    fi
}

# Automatically exit if any of the subsequent commands fail.
# NOTE: This option will be disabled further down in the script.
set -e

# Find the directory path of setup.sh.
SCRIPT_DIR="$( cd -- "$( dirname -- "$0" )" > /dev/null 2>&1 && pwd -P )"

CONFIG_BACKUP_DIR="$SCRIPT_DIR/config_backups"

# vim setup
echo "Creating symlink to $SCRIPT_DIR/.vimrc at $HOME/.vimrc ."

if [ -e "$HOME/.vimrc" ]; then
    echo ".vimrc already exists at $HOME !"
    safe_mv "$HOME/.vimrc" "$CONFIG_BACKUP_DIR"
fi

ln -fs -- "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc"

echo ".vimrc symlink created."

if [ -e "$HOME/.vim" \
     -a "$(cd -- "$HOME/.vim" > /dev/null 2>&1 && pwd -P )" = "$SCRIPT_DIR" \
   ]; then
    echo "$HOME/.vim same as script directory."
    echo ".vim symlink not required."
else
    if [ -e "$HOME/.vim" ]; then
        echo "A different .vim already exists at $HOME !"
        safe_mv "$HOME/.vim" "$CONFIG_BACKUP_DIR"
    fi
    echo "Creating symlink to $SCRIPT_DIR at $HOME/.vim ."
    ln -fs -- "$SCRIPT_DIR" "$HOME/.vim"
    echo ".vim symlink created."
fi

# nvim setup
if [ ! -z "$XDG_CONFIG_HOME" ]; then
    if [ ! -e "$XDG_CONFIG_HOME" ]; then
        mkdir -p -- "$XDG_CONFIG_HOME"
    fi
    NVIM_DIR="$XDG_CONFIG_HOME/nvim"
else
    if [ ! -e "$HOME/.config" ]; then
        mkdir -p -- "$HOME/.config"
    fi
    NVIM_DIR="$HOME/.config/nvim"
fi

if [ -e "$NVIM_DIR" ]; then
    echo "nvim config directory already exists at $NVIM_DIR !"
    safe_mv "$NVIM_DIR" "$CONFIG_BACKUP_DIR"
fi

ln -fs -- "$SCRIPT_DIR/nvim" "$NVIM_DIR"

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

echo "Attempting to install plugins."
vim +PlugUpgrade +PlugUpdate +qall
if [ $? -ne 0 ]; then
    echo "Automatic plugin installation failed for Vim!"
    echo "Open Vim and execute ':PlugUpgrade' and ':PlugUpdate'" \
         "for manual installation."
else
    echo "Plugins installed for Vim."
fi

nvim +PlugUpgrade +PlugUpdate +qall
if [ $? -ne 0 ]; then
    echo "Automatic plugin installation failed for nvim!"
    echo "Open nvim and execute ':PlugUpgrade' and ':PlugUpdate'" \
         "for manual installation."
else
    echo "Plugins installed for nvim."
fi
