set t_u7=
set t_RV=
" Bail out if something that ran earlier, e.g. a system wide vimrc, does not
" want Vim to use these default values.
if exists('skip_defaults_vim')
    finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
" Avoid side effects when it was already reset.
if &compatible
    set nocompatible
endif

" When the +eval feature is missing, the set command above will be skipped.
" Use a trick to reset compatible only when the +eval feature is missing.
silent! while 0
set nocompatible
silent! endwhile

" Do incremental searching when it's possible to timeout.
if has('reltime')
    set incsearch
endif

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" Don't use Ex mode, use Q for formatting.
" Revert with ":unmap Q".
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <C-U> <C-G>u<C-U>

let no_buffers_menu=1

" Switch syntax highlighting on when the terminal has colors or when using the
" GUI (which always has colors).
if &t_Co > 2 || has("gui_running")
    " Revert with ":syntax off".
    syntax on

    " I like highlighting strings inside C comments.
    " Revert with ":unlet c_comment_strings".
    let c_comment_strings=1
endif

" Only do this part when Vim was compiled with the +eval feature.
if 1

    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    " Revert with ":filetype off".
    filetype plugin indent on

    " Put these in an autocmd group, so that you can revert them with:
    " ":augroup vimStartup | au! | augroup END"
    augroup vimStartup
        au!

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid, when inside an event handler
        " (happens when dropping a file on gvim) and for a commit message (it's
        " likely a different one than last time).
        autocmd BufReadPost *
                    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                    \ |   exe "normal! g`\""
                    \ | endif

    augroup END

endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
    " Prevent that the langmap option applies to characters that result from a
    " mapping.  If set (default), this may break plugins (but it's backward
    " compatible).
    set nolangremap
endif

autocmd filetype python set expandtab
autocmd FileType c,cpp  setlocal path+=/usr/include include&
autocmd FileType javascript setlocal tabstop=2

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start
set history=1000		" keep 200 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set wildmenu		" display completion matches in a status line

set ttimeout		" time out for key codes
set ttimeoutlen=100	" wait up to 100ms after Esc for special key

" Show @@@ in the last line if it is truncated.
set display=truncate

" Show a few lines of context around the cursor.  Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * checktime

" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

set path+=**
set termguicolors
set background=dark
set hidden
set whichwrap+=<,>,h,l
set ignorecase
set smartcase
set hlsearch
set lazyredraw
set magic
set showmatch
set mat=2
set number
set nuw=4
set relativenumber
set noshowmode
set shiftwidth=4
set tabstop=4
set shiftround
set wrap
set linebreak
set nolist
set showbreak=…
set textwidth=500

set autoindent
set smartindent

set cursorline
hi clear CursorLine
hi CursorLineNR cterm=bold ctermfg=white guifg=white

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

set laststatus=2

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

" Create tags file
command! MakeTags !ctags -R .

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" All the plugins go in here

" Language Client
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" TypeScript Highlighting
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

" Git plugin
Plug 'tpope/vim-fugitive'

" Colored Parentheses
Plug 'luochen1990/rainbow'

" Vim-Polyglot
Plug 'sheerun/vim-polyglot'

" Air line for bottom bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" NERDTree
Plug 'scrooloose/nerdtree'

" Surround plugin
Plug 'tpope/vim-surround'

" Commentary plugin for comments
Plug 'tpope/vim-commentary'

" Colorschemes

" Onedark colorscheme
Plug 'joshdick/onedark.vim'

" Dracula colorscheme
Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'tomasr/molokai'

Plug 'sonph/onehalf', {'rtp': 'vim/'}

Plug 'sainnhe/sonokai'

Plug 'lifepillar/vim-solarized8'

Plug 'ayu-theme/ayu-vim'

Plug 'srcery-colors/srcery-vim'

Plug 'mhinz/vim-janah'

" Developer icons
Plug 'ryanoasis/vim-devicons'

Plug 'junegunn/fzf.vim'

Plug 'simeji/winresizer'

Plug 'dart-lang/dart-vim-plugin'

" Startify
Plug 'mhinz/vim-startify'

" Indent Line
" Plug 'Yggdroot/indentLine'

" vim-plug
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

" Initialize plugin system
call plug#end()

" Plugins config

let g:coc_global_extensions = ['coc-emmet', 'coc-flutter', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver']
" Some prettier setup
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

" let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" let g:indentLine_setColors = 0

let g:airline_theme='solarized'
let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_powerline_fonts = 1

" let ayucolor="mirage"
colorscheme solarized8_flat

let g:rainbow_active = 1

let g:Hexokinase_highlighters = [ 'backgroundfull' ]


" Keymaps

nmap <silent> <leader>f :NERDTreeToggle<cr>

" Press Space to turn off highlighting and clear any message already displayed.
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Use paste mode
set pastetoggle=<F2>

" fzf
nnoremap <C-p> :Files<Cr>

" Clear Trailing white spaces
nmap <leader>c :call CleanExtraSpaces()<CR>:echo<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Put these lines at the very end of your vimrc file.

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
