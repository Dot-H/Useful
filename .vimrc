" Global settings
:set mouse=
:set nocompatible
:syntax on
:set splitright " Split window on the right

:set shiftwidth=4
:set tabstop=4
:set expandtab

:set autoindent
:set smartindent
:set cindent

:set background=dark
:hi Normal ctermbg=16

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
: let @a = toupper(expand('%t'))
: let @a = '#ifndef ' . @a . "\n" . '# define ' . @a . "\n\n\n" . '#endif /* !'.@a.' */'
" Write the macros
: normal "ap
" Replace dots by underscores
: execute '%s/\./_/g'
endfunction

function Header_hh()
" Get the file name and upper it
: let @a = '#pragma once'
" Write the macros
: normal "ap
endfunction

" Write the macros in new .h files
:autocmd BufNewFile *.h call Header_h()

" Write the macros in new .hh files
:autocmd BufNewFile *.hh call Header_hh()

" Remove the \t when opening *h, *c, *cpp, *hh
" :autocmd QuitPre *.h,*.hh,*.c, *.cc, *.cpp :execute 'ret'

" Show when a line exceeds 80 chars
:au BufWinEnter *.* let w:m1=matchadd('ErrorMsg', '\%>80v.\+', -1)

function Shebang(interpreter)
: let @a = "#!/bin/" . a:interpreter
: normal "ap
endfunction

" Add Shebang when create script
:au BufNewFile *.sh call Shebang("sh")
:au BufNewFile *.cl call Shebang("clisp")

function C_test_file()
: let @a = "#include <stdio.h>\n\n"
: let @a = @a . "int main(int argc, char* argv[])\n{\n}"
: normal "ap
endfunction

function Cpp_test_file()
: let @a = "#include <iostream>\n\n"
: let @a = @a . "int main(int argc, char* argv[])\n{\n}"
: normal "ap
endfunction

" Create a c test file
:au BufNewFile test.c call C_test_file()

" Create a cpp test file
:au BufNewFile test.cpp call Cpp_test_file()

augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

map <C-K> :pyf /usr/share/clang/clang-format.py<cr>
imap <C-K> <c-o>: /usr/share/clang/clang-format.py<cr>

vnoremap <c-f> y<ESC>/<c-r>"<CR>

function! SyntasticCheckHook(errors)
    if !empty(a:errors)
        let g:syntastic_loc_list_height = min([len(a:errors), 4])
    endif
endfunction

execute pathogen#infect()
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

function Syntastic_add_header(name)
: let path = expand('#a:name:p')
: let g:syntastic_c_avrgcc_args = "-l". path
: let g:syntastic_c_gcc_args = "-l". path
endfunction

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_c_checkers = ['avrgcc', 'gcc']

" git config --add vim.settings 'tabstop=4 expandtab'
let git_settings = system("git config --get vim.settings")
if strlen(git_settings)
    exe "set" git_settings
endif


" Cscope
if has("cscope")
    " Use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag 

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0
    map g<C-]> :cs find 3 <C-R>=expand("<cword>")<CR><CR>
    map g<C-\> :cs find 0 <C-R>=expand("<cword>")<CR><CR>

    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.
    "
    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one (vim 6 and up only)
    nmap <C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>

    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    nmap <C-@><C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>
endif 
