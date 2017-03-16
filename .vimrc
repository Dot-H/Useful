" Globat settings
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

:command -nargs=0 Header normal o/* Author: Alexandre BERNARD<enter>Company: Epita<enter>Functions used: None<enter>Purpose: 42<enter>Version: 1.0<enter>Modifications: None */<esc>

:command -nargs=0 Noindent :execute 'set noautoindent' | :execute 'set nosmartindent' | :execute 'set nocindent'

:function RemoveSp()
: execute "1,$s/[ \t]*$//"
:endfunction

" Remove the useless spaces at the end of a line
:command -nargs=0 Spaces call RemoveSp() 

" Remove the useless spaces at the end of a line when we quit vim
:autocmd QuitPre * call RemoveSp()
