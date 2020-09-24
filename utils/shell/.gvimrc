" Following is for Making tab width = 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

" Following are general settings
set ignorecase incsearch hlsearch autoindent nu

" Learn meaning of following
set showmode showcmd wrap ruler noswf sm nocompatible showmatch title
set laststatus=2
set cindent
set smarttab
set guifont=Monospace\ 11
set titlestring=VIM:\ %F
se diffopt+=iwhite
set background=light
syntax enable
syntax on
filetype on
set bs=2
set wildmenu
set wildmode=list:full
set viminfo='20,\"50          " Read/write a .viminfo file, don't store more than 50 lines of registers
set history=50                " Keep 50 lines of command line history
set cinoptions=(0
set cinkeys=0{,0},:,;,o,!<Tab>,0#,!^F


" Only do this part when compiled with support for autocommands.
if has("autocmd")

autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

" When starting to edit a file:
"   For C and C++ files set formatting of comments and set C-indenting on.
"   For other files switch it off.
"   Don't change the order, it's important that the line with * comes first.
autocmd FileType *      set formatoptions=tcql nocindent comments&
autocmd FileType c,cpp  set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,://


augroup gzip
" Remove all gzip autocommands
au!

" Enable editing of gzipped files
" set binary mode before reading the file
autocmd BufReadPre,FileReadPre    *.gz,*.bz2 set bin
autocmd BufReadPost,FileReadPost  *.gz call GZIP_read("gunzip")
autocmd BufReadPost,FileReadPost  *.bz2 call GZIP_read("bunzip2")
autocmd BufWritePost,FileWritePost    *.gz call GZIP_write("gzip")
autocmd BufWritePost,FileWritePost    *.bz2 call GZIP_write("bzip2")
autocmd FileAppendPre         *.gz call GZIP_appre("gunzip")
autocmd FileAppendPre         *.bz2 call GZIP_appre("bunzip2")
autocmd FileAppendPost        *.gz call GZIP_write("gzip")
autocmd FileAppendPost        *.bz2 call GZIP_write("bzip2")

    " After reading compressed file: Uncompress text in buffer with "cmd"
fun! GZIP_read(cmd)
    " set 'cmdheight' to two, to avoid the hit-return prompt
    let ch_save = &ch
    set ch=3
    " when filtering the whole buffer, it will become empty
    let empty = line("'[") == 1 && line("']") == line("$")
let tmp = tempname()
    let tmpe = tmp . "." . expand("<afile>:e")
    " write the just read lines to a temp file "'[,']w tmp.gz"
    execute "'[,']w " . tmpe
    " uncompress the temp file "!gunzip tmp.gz"
    execute "!" . a:cmd . " " . tmpe
    " delete the compressed lines
    '[,']d
    " read in the uncompressed lines "'[-1r tmp"
    set nobin
    execute "'[-1r " . tmp
    " if buffer became empty, delete trailing blank line
    if empty
    normal Gdd''
    endif
    " delete the temp file
call delete(tmp)
    let &ch = ch_save
    " When uncompressed the whole buffer, do autocommands
    if empty
    execute ":doautocmd BufReadPost " . expand("%:r")
    endif
    endfun

    " After writing compressed file: Compress written file with "cmd"
fun! GZIP_write(cmd)
    if rename(expand("<afile>"), expand("<afile>:r")) == 0
    execute "!" . a:cmd . " <afile>:r"
    endif
    endfun

    " Before appending to compressed file: Uncompress file with "cmd"
fun! GZIP_appre(cmd)
    execute "!" . a:cmd . " <afile>"
    call rename(expand("<afile>:r"), expand("<afile>"))
    endfun

    augroup END

endif " has("autocmd")

" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim... 
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " add any cscope database in current directory
    "if filereadable("cscope.out")
    "   cs add cscope.out  
    " else add the database pointed to by environment variable 
    " elseif $CSCOPE_DB != ""
    "    cs add $CSCOPE_DB
    "endif

    " show msg when any other cscope db added
    set cscopeverbose  


    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


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


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>	

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>	


    " Hitting CTRL-space *twice* before the search type does a vertical 
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout 
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout 
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

endif


map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
map <F7> :tp<CR>
map <F2> :set tag=/wrk/xhdhdnobkup3/sanchayk/RDI_vivado_sandbox/Rodin/HEAD/src/tags  <CR>
map <F3> :set tag=/proj/xhdhdstaff3/sanchayk/vivado_sandbox/Rodin/HEAD/src/tags <bar> :colorscheme morning  <CR>
"map <F2> :set tag=/wrk/xhdhdnobkup3/sanchayk/rdi_sandbox/Rodin/HEAD/src/tags <bar> :colorscheme darkblue  <CR>
"map <F3> :set tag=/proj/xhdhdstaff3/sanchayk/sanchayk_sandbox/Rodin/HEAD/src/tags <bar> :colorscheme desert  <CR>
map <F8> :tn<CR>
map! <S-Insert> <MiddleMouse>
nnoremap <C-N> :bn<CR>
nnoremap <C-P> :bp<CR>
"opens up the present working directory for browsing
nnoremap <C-O> :e `pwd` <CR>
:nmap ctrl-] :vert stag!<CR>
