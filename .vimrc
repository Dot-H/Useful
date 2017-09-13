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

" Allows space in normal mod
:nnoremap <space> i<space><esc>

" Allows enter to insert new line
:nnoremap <CR> o<esc>

" Save file with ctrl+s
:inoremap <C-s> <Esc>:w<CR>a

" Put a function header
:command -nargs=0 Header :execute 'r ~/usefull/ressources/header'

" Disable the indents
:command -nargs=0 Noindent :execute 'set noautoindent' | :execute 'set nosmartindent' | :execute 'set nocindent'

:function Set_all_indents()
: execute "set autoindent"
: execute "set smartindent"
: execute "set cindent"
:endfunction

" Able all the indents
:command -nargs=0 Indent call Set_all_indents()

function Create_dot_h()
: execute "!python ~/usefull/ressources/create_dot_h.py ".expand('%t')
: let @a = "#include \"".expand('%t')."\"\n"
: normal gg0"ap
: normal ggj$hxih
endfunction

" Create a dot_h file
:command -nargs=0 DotH call Create_dot_h()

:function RemoveSp()
: execute "1,$s/[ \t]*$//"
:endfunction

" Remove the useless spaces at the end of a line
:command -nargs=0 Spaces call RemoveSp()

" Remove the useless spaces at the end of a line when we quit vim
:autocmd QuitPre * call RemoveSp()

function Header_h()
" Get the file name and upper it
: let @a = toupper(expand('%t')) . '_'
: let @a = '#ifndef ' . @a . "\n" . '# define ' . @a . "\n\n\n" . '#endif /* !'.@a.' */'
" Write the macros
: normal "ap
" Replace dots by underscores
: execute '%s/\./_/g'
endfunction

" Write the macros in new .h and .hh files
:autocmd BufNewFile *.h,*.hh call Header_h()

" Remove the \t when opening *h, *c, *cpp, *hh
:autocmd QuitPre *.h,*.hh,*.c,*.cpp :execute 'ret'

" Show when a line exceeds 80 chars
:au BufWinEnter * let w:m1=matchadd('ErrorMsg', '\%>80v.\+', -1)

function Shebang()
: let @a = "#!/bin/sh"
: normal "ap
endfunction

" Add Shebang when create .sh
:au BufNewFile *.sh call Shebang()

function C_test_file()
: let @a = "#include <stdio.h>\n\n"
: let @a = @a . "int main(int argc, char* argv[])\n{\n}"
: normal "ap
endfunction

" Create a c test file
:au BufNewFile test.c call C_test_file()
