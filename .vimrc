" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2014 Nov 05
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Set color scheme
colorscheme koehler

" Move up to 1000 lines between files
set viminfo='100,<1000,s100,h

" Allow tabbing ovr a visual selection
vmap <Tab> >gv
vmap <S-Tab> <gv

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Convert tabs to double spaces
set tabstop=2 shiftwidth=2 expandtab

" Turn on line numbers
set number

" Place backup files and swap files in .vimtmp directory
set backupdir=~/.vimtmp//,.
set directory=~/.vimtmp//,.
set undodir=~/.vimtmp//,.

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif





" Automatically *soft-wrap* text at the edge of the window
" https://stackoverflow.com/questions/36950231/auto-wrap-lines-in-vim-without-inserting-newlines
set number " (optional - will help to visually verify that it's working)
set textwidth=0
set wrapmargin=0
set wrap
set linebreak " (optional - breaks by word rather than character)




" show current file in status bar
set laststatus=2
" Add a cool status bar
" Taken 2026-02-50 from https://stackoverflow.com/a/9121083
function! InsertStatuslineColor(mode)
  if a:mode == 'i' " insert
    hi statusline guifg=Cyan ctermfg=Cyan guibg=Black ctermbg=Black
  elseif a:mode == 'r' " replace
    hi statusline guifg=Red ctermfg=Red guibg=Black ctermbg=Black
  elseif a:mode == 'v' " visual. doesn't seem to work?
    hi statusline guifg=LightGray ctermfg=LightGray guibg=DarkGray ctermbg=DarkGray
  elseif a:mode == 'n' " normal
    hi statusline guifg=Magenta ctermfg=Magenta guibg=Black ctermbg=Black
  else " command (:d, operator-pending (no)
    hi statusline guifg=DarkGrey ctermfg=1 guibg=Black ctermbg=Black
  endif
endfunction

au InsertEnter * call InsertStatuslineColor(v:insertmode)
au InsertLeave * call InsertStatuslineColor(mode()) " hi statusline guibg=DarkGrey ctermfg=8 guifg=White ctermbg=15

" default the statusline to green when entering Vim
call InsertStatuslineColor(mode())

" Formats the statusline
set statusline=%f                           " file name
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%y      "filetype
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

" 2026-02-09 Disabled these as it relies on multiple vim plugins that I
" haven't bothered to install
" Puts in the current git status
"    if count(g:pathogen_disabled, 'Fugitive') < 1
"        set statusline+=%{fugitive#statusline()}
"    endif

" Puts in syntastic warnings
"    if count(g:pathogen_disabled, 'Syntastic') < 1
"        set statusline+=%#warningmsg#
"        set statusline+=%{SyntasticStatuslineFlag()}
"        set statusline+=%*
"    endif

set statusline+=\ %=                        " align left
set statusline+=Line:%l/%L[%p%%]            " line X of Y [percent of file]
set statusline+=\ Col:%c                    " current column
set statusline+=\ Buf:%n                    " Buffer number
set statusline+=\ [%b][0x%B]\               " ASCII and byte code under cursor
" ---- end section stolen from StackOverflow post
