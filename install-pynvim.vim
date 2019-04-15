set nocompatible

if has('nvim')
    echo 'Vim not found. vim executable points to nvim.'
else
    if has('python3')
        pythonx << EOF
import sys
import subprocess
subprocess.call([
    sys.executable, '-m', 'pip', 'install', '--user', 'pynvim'])
EOF
    else
        echo 'No python3 support for Vim. pynvim not installed.'
    endif
endif
