#!/bin/bash

VIM_SM_ROOT=/home/ec2-user/SageMaker
VIM_RTP=${VIM_SM_ROOT}/.vim
VIMRC=${VIM_SM_ROOT}/.vimrc

apply_vim_setting() {
    # vimrc
    rm /home/ec2-user/.vimrc
    ln -s ${VIMRC} /home/ec2-user/.vimrc

    echo "Vim initialized"
}

if [[ ! -f ${VIM_RTP}/_SUCCESS ]]; then
    echo "Initializing vim from ${VIMRC_SRC}"

    # vimrc
    cat << EOF > ${VIMRC}
set rtp+=${VIM_RTP}

" Hybrid line numbers
"
" Prefer built-in over RltvNmbr as the later makes vim even slower on
" high-latency aka. cross-region instance.
:set number relativenumber
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" Relative number only on focused-windows
autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &number | set relativenumber   | endif
autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &number | set norelativenumber | endif

" Remap keys to navigate window aka split screens to ctrl-{h,j,k,l}
" See: https://vi.stackexchange.com/a/3815
"
" Vim defaults to ctrl-w-{h,j,k,l}. However, ctrl-w on Linux (and Windows)
" closes browser tab.
"
" NOTE: ctrl-l was "clear and redraw screen". The later can still be invoked
"       with :redr[aw][!]
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

set laststatus=2
set hlsearch
set colorcolumn=80
set splitbelow
set splitright

"set cursorline
"set lazyredraw
set nottyfast

autocmd FileType help setlocal number

""" Coding style
" Prefer spaces to tabs
set tabstop=4
set shiftwidth=4
set expandtab
set nowrap
set foldmethod=indent
set foldlevel=99

""" Shortcuts
map <F3> :set paste!<CR>
" Use <leader>l to toggle display of whitespace
nmap <leader>l :set list!<CR>

" Highlight trailing space without plugins
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$/

" Terminado supports 256 colors
set t_Co=256
colorscheme delek
"colorscheme elflord
"colorscheme murphy
"colorscheme ron
highlight colorColumn ctermbg=237

EOF
    mkdir -p ${VIM_RTP}
    touch ${VIM_RTP}/_SUCCESS
fi

apply_vim_setting

