" Global settings
:set nocompatible
:syntax on

:set hlsearch
:set shiftwidth=2
:set tabstop=2
:set expandtab

:set autoindent
:set smartindent
:set cindent

:set background=dark
 
" Show line number
:set number

" Show when a line exceeds 80 chars
:au BufWinEnter * let w:m1=matchadd('ErrorMsg', '\%>80v.\+', -1)

" Allows space in normal mod
:nnoremap <space> i<space><esc>

" Allows enter to insert new line
:nnoremap <CR> o<esc>
