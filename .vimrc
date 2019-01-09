"|---------------------------------------------------------------------------|"
"|                Personal .vimrc file of uniq10                             |"
"|---------------------------------------------------------------------------|"

" Use Vim settings instead of Vi settings.
" This must be first as it changes other options as a side effect.
set nocompatible

" Unset all autocommands.
:autocmd!

" Local variable to store a list of warning messages.
let s:warnmsglist = []

function AddWarning(msg)
    call add(s:warnmsglist, a:msg)
endfunction

function PrintWarningMsgs(msglist)
    for msg in a:msglist
        echohl WarningMsg
        echo 'Warning: '
        echohl None
        echon msg
    endfor
endfunction

" Manage plugins with plug.vim.
call plug#begin('~/.vim/plugged')

" Get Tomorrow theme bundle.
Plug 'https://github.com/chriskempson/tomorrow-theme.git', { 'rtp': 'vim' }


" Get deoplete autocompletion system for nvim or Vim8.
" deoplete requires python3 support.
if !has('python3')
    call AddWarning(join([
        \ 'deoplete will not work since python3 support not found.',
        \ 'Try `pip3 --user --upgrade install neovim` if using neovim/Vim8',
        \ 'and run :PlugUpdate after.'
        \ ], "\n\t"))
elseif has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
elseif v:version >= 800
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
else
    call AddWarning('Not using neovim/Vim8. deoplete will not work.')
endif

call plug#end()

" Make backspace behave normally in insert mode.
set backspace=indent,eol,start

" Switch on syntax highlighting.
syntax on

" Use Tomorrow-Night-Bright theme.
colorscheme Tomorrow-Night-Bright

" Enable file type detection and language specific indenting.
filetype plugin indent on

" Show line numbers.
set number

" Allow hidden buffers.
set hidden

" Add a colored column at 80 to indicate standard column size.
set colorcolumn=80


" Increase command history to 100.
" Change default viminfo settings to give preference to the value of history.
set viminfo=<100,'20,f1,s100
"           |    |   |  + registers with more than 100KB skipped.
"           |    |   + store file marks.
"           |    + remember marks for 20 previously edited files.
"           + store maximum 100 lines for each register.
set history=100

" Set default tab behaviour to 4 spaces and enable autoindenting.
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent

" Add search higlighting, realtime matching and smart case-insensitive search.
set hlsearch
set incsearch
set ignorecase
set smartcase

" Add window switching shortcuts.
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
if has('nvim')
    tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
endif

" Show matching parantheses.
set showmatch

" Use UTF-8 encoding by default.
set encoding=utf-8

" Disable backups and store swap files at $HOME/.vim/swp/.
set nobackup
set swapfile
set directory^=$HOME/.vim/swp/


" deoplete autocompletion settings.

" Enable deoplete.
let g:deoplete#enable_at_startup=1
" Use TAB to cycle through suggestions.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Map jj in insert mode to <Esc>.
inoremap jj <Esc>

" Add :RemTrailingSp command to remove trailing whitespaces.
command RemTrailingSp %s/\s\+$//e


" Automatically remove trailing whitespaces if the file, when opened, didn't
" have any trailing whitespace.

" Set a flag if a new file has trailing whitespaces when opened.
autocmd BufReadPost * :if(search('\s\+$', 'nw')) | let b:inithastrailingsp = 1
" Remove trailing whitespaces if the whitespace flag is not set.
autocmd BufWritePre * :if((!exists('b:inithastrailingsp'))
                      \   || (!b:inithastrailingsp)) | RemTrailingSp

autocmd VimEnter * call PrintWarningMsgs(s:warnmsglist)
