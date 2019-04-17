"|---------------------------------------------------------------------------|"
"|                Personal .vimrc file of uniq10                             |"
"|---------------------------------------------------------------------------|"

" Use Vim settings instead of Vi settings.
" This must be first as it changes other options as a side effect.
set nocompatible

" Unset all autocommands.
autocmd!


" Set python options
if has('nvim')
    let s:python3_bin = expand('~/.vim/venv/bin/python3')
    let g:python3_host_prog = s:python3_bin
endif

" Force python3 if possible
" This must be done after python3_host_prog is set for nvim
if has('python3')
endif


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
call plug#begin(expand('~/.vim/plugged'))

" Get Tomorrow theme bundle.
Plug 'https://github.com/chriskempson/tomorrow-theme.git', { 'rtp': 'vim' }


" Get deoplete autocompletion system for nvim or Vim8.
" deoplete requires python3 support.
if has('nvim')
    if !has('python3')
        call AddWarning(join([
            \ 'deoplete will not work since python3 support not found.',
            \ 'Execute `' . s:python3_bin . ' -m pip install --upgrade pynvim`',
            \ 'if using neovim and run :PlugUpdate after.'
            \ ], "\n\t"))
    else
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    endif
elseif v:version >= 800 && has('python3')
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
else
    call AddWarning(
        \ 'Not using neovim/Vim8 with python3 support. deoplete will not work.')
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

" Use <Space> as leader
let mapleader=' '
nnoremap <Space> <Nop>

" Add window switching shortcuts.
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l

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

" Use jj in terminal insert mode to escape insert mode
if has('nvim')
    tnoremap jj <C-\><C-n>
endif

" Use mouse
set mouse=a

" Add :RemTrailingSp command to remove trailing whitespaces.
let s:trailingSpRegex='\(\s\+$\)\|\(\($\n\s*\)\+\%$\)'
command RemTrailingSp :execute '%s/' . s:trailingSpRegex . '//ge'


" Automatically remove trailing whitespaces if the file, when opened, didn't
" have any trailing whitespace.

" Set a flag if a new file has trailing whitespaces when opened.
autocmd BufReadPost * :if(search(s:trailingSpRegex, 'nw'))
                      \ | let b:inithastrailingsp = 1
" Remove trailing whitespaces if the whitespace flag is not set.
autocmd BufWritePre * :if((!exists('b:inithastrailingsp'))
                      \   || (!b:inithastrailingsp)) | RemTrailingSp

" Disable line numbers in terminal mode.
if has('nvim')
    autocmd TermOpen * setlocal nonumber norelativenumber
endif

autocmd VimEnter * call PrintWarningMsgs(s:warnmsglist)
