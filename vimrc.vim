" .vimrc config file, za in normal mode to expand code folds.
" I've moved a fair chunk of advanced things to .vim/plugins/
" as separate files.

" {{{ BASIC VIM STUF
" GENERAL CONFIG {{{
set nocompatible " set not vi mode
set updatetime=100 " For async plugins like gitgutter.

" Put swapfiles in home so it doesn't create clutter for VCS
" // is some hot magic that will make the pathname slashes into % in the
" filenames.
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" General 
set splitright        " vsplit right always
set splitbelow        " Hsplit below always
set equalalways       " always split 50% if not explicitly defined
set tabstop=2         " Tabs being 2 spaces rather than 4
set softtabstop=0 
set expandtab         " expand tabs to white space
set cursorline        " Setting underline on the current line.
set cursorcolumn      " setting highlighting on the current column
set showcmd           " Showing commands in normal mode because im a rube
set path+=**          " Adding recursive path searching to :file.
set wildmenu          " Setting the autocomplete menu
set bs=2              " Setting Backspace
set mouse=a           " Scroll with mouse scrolly
set spell             " Enabling spellcheck by default

" Searching 
set hlsearch          " Highlight searching with *
set showmatch         " Highlight the matching brackety [{()}]
set incsearch         " Search the file as typing.

" for CSV files
let g:csv_delim=','

syntax enable " Enable syntax highlighting

" Will attempt to load plugins base on filetype loaded like python.vim for a
" *.py file.
filetype plugin on 

" vim has a penchant for redrawing the screen when nothing has changed, this
" should make it redraw on changes will make some macros and other things faster
set lazyredraw

" Setting the system clipboard to be the default register so y D and P work
" with it.
set clipboard=unnamed

" for vimgrepi and quickfix windows, open results in new tab
set switchbuf+=usetab,newtab

" Autocommand for changing the cursorline when entering insert mode
autocmd InsertEnter * highlight CursorLine term=underline ctermbg=Black 
autocmd InsertEnter * highlight CursorColumn term=reverse ctermbg=Black
autocmd InsertLeave * highlight CursorLine term=underline ctermbg=237 
autocmd InsertLeave * highlight CursorColumn term=reverse ctermbg=237
""" END GENERAL }}}
" GENERAL MAPPINGS {{{
" My leader is \, its the defualt but I'll set it here too JIC something
" decides to change in the future.
let mapleader = '\'

nmap <leader>ct : tabclose<CR>  " Close the current tab.
nmap <leader>s  : mksession<CR> " Save the current session, reopen with vim -S
nmap <leader>y  : call YankAll()<CR> 

" Mappings for vimgrep
noremap <F12>     : cnext<CR>
noremap <F11>     : cprev<CR>
noremap <S-F12>   : cnfile<CR>
noremap <S-F11>   : cpfile<CR>

" Map drop data in buffer.
noremap <F4><F4>  : normal ggdG<CR>

" Terminal mappings
tnoremap <F12> <C-W>N  " Switch to normal mode

""" END MAPPINGS }}}
" BASIC COMMANDS {{{
" Some basic useful commands
command! Squash       
  \ :%s/\s\+$// " Remove trailing whitespace
command! Squish       
  \ :g/^\s*$/d " Remove blank lines

" Remove pesky smart quotes
command! SmartQuote
  \ :% s/[”“]/"/ge | :% s/[‘’]/'/ge

" Pretty Print things
command! PPrintJSON
  \ :%!python3 -m json.tool

command! PPrintXML
  \ :%!python3 -c 
  \ 'import xml.dom.minidom as a, sys; print(a.parse(sys.stdin).toprettyxml())'

command! PPrintXMLSel
  \ :'<, '>!python3 -c 
  \ 'import xml.dom.minidom as a, sys; print(a.parse(sys.stdin).toprettyxml())'

" Unescape XML strings.
command! UnstringEscapedXML
  \ :%s/\(^"\|"$\)//ge |
  \ :%s/\\n/\r/ge |
  \ :%s/\\t/  /ge |
  \ :%s/\\//g

" Show command chars and whitespace
command! ShowInvisi   :setlocal list!
command! HideInvisi   :setlocal nolist!

" Change tab size if needed
command! Tab4         :set tabstop=4
command! Tab2         :set tabstop=2

" Spaces for tab.
command! TabsToSpaces :set expandtab
command! ConvertTabs  :%s/	/    /g

" toggle line length highlight
command! -nargs=1 ColHL :call ToggleColorCol(<args>)

" Enable spellcheck
command! Spellcheck  :call ToggleSpell()

" vimgrep recursively
command! -nargs=1 VimGrepR :vimgrep '<args>' **/*

" Undos a file and redos a file.
command! UnDOS 
  \  update | let currff = &ff | e ++ff=dos | setlocal ff=unix | w | exe 'set ff='.expand(currff)
command! ReDOS \
  \  update | let currff = &ff | e ++ff=dos | w | exe 'set ff='.expand(currff) 

""" END BASIC COMMANDS }}}
" FUNCTIONS {{{
" toggle highlight line for max line len.
function! ToggleColorCol(length)
  if a:length == 0
  	set colorcolumn&
  else
    let &l:colorcolumn=a:length
  endif
endfunction

" toggle spellcheck
function! ToggleSpell()
	if &spell == 'nospell'
		setlocal spell
	else
		setlocal nospell
	endif
endfunction

" Strip a string of whitespace for vim versions earlier than 8.0.1630
function! Strip(mystring)
  return substitute(a:mystring, '^\s*\(.\{-\}\)\s*$', '\1', '')
endfunction

" Yankall
function! YankAll()
			let save_cursor = getcurpos()
			normal! ggVGY
      call setpos('.', save_cursor)
      unlet save_cursor
endfunction
""" END FUNCTIONS }}}
" FILETYPES {{{
" For python, automagically change formatting.
let g:python_highlight_all = 1

 autocmd FileType python 
  \ setlocal tabstop=4 | setlocal shiftwidth=4 | setlocal expandtab | 
  \ setlocal autoindent | setlocal foldmethod=indent | :ColHL 121

""" END FILETYPES }}}
" COLOR SCHEME {{{
" I like the gruvbox dark background better with harder contrasts.
set background=dark
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = '0'
colo gruvbox 

" Color column should be red
hi ColorColumn ctermbg=DarkRed

" Comments are a bit dark
hi Comment ctermfg=Blue

" Color scheme for vimdiff which GitGutter also uses
hi DiffAdd    cterm=BOLD ctermfg=NONE ctermbg=17
hi DiffDelete cterm=BOLD ctermfg=NONE ctermbg=52
hi DiffChange cterm=BOLD ctermfg=NONE ctermbg=23
hi DiffText   ctermfg=NONE ctermbg=24 

" Colors for windows to see what's active blue vs red
hi StatusLine   ctermfg=16  ctermbg=Blue cterm=bold
hi StatusLineNC ctermfg=White ctermbg=DarkRed cterm=none 
" Adding terminal colors for vim8 terminal functions.
hi StatusLineTerm   ctermfg=16  ctermbg=Blue cterm=bold
hi StatusLineTermNC ctermfg=White ctermbg=DarkRed cterm=none 
" Adding color for vertical split
hi VertSplit term=reverse ctermfg=12 ctermbg=0

" Setting the currently select item in the command menu
hi WildMenu     ctermfg=White ctermbg=DarkBlue

" Colors for the autocorrect popup menu.
hi Pmenu ctermfg=16 ctermbg=Blue cterm=bold
hi PmenuSel ctermfg=White ctermbg=DarkBlue cterm=bold

" Colors for the tabline
hi TabLineSel ctermbg=DarkBlue ctermfg=White cterm=Bold
hi TabLine ctermbg=Blue ctermfg=16
hi TabLineFill ctermbg=Blue
""" END COLORS }}}
" }}}
" {{{ ADVANCED VIM STUFF
" CODE FOLDING {{{
set foldenable        " Enable code folding
set foldlevelstart=10 " Only fold some pretty nested blocks 
set foldnestmax=10    " only allow up to 10 nested folds, if > code is lunacy.
set foldmethod=indent " Fold based on indentation, good for python

" }}}
" AUTOCOMPLETE {{{
" With these settings it should be possible to open up a menu while typing in
" insert mode with <TAB>
set omnifunc=syntaxcomplete#Complete " Setting where omnicomplete is pulled
set completeopt=menuone,noinsert      " Auto pop longest term and pull up menu
set complete-=i  " Removing includes, this seems to take forever on some files
set complete+=k/usr/share/dict/words " Adding dictionary
" even if there is only one autocomplete result.

" Function to bind tab to open autocomplete menu
" source: https://vim.fandom.com/wiki/Autocomplete_with_TAB_when_typing_words
function! Tab_Or_Complete()
  if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
    return "\<C-N>"
  else
    return "\<Tab>"
  endif
endfunction
inoremap <Tab> <C-R>=Tab_Or_Complete()<CR>

" Pressing enter should accept and not insert a newline
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

""" AUTOCOMPLETE END }}}
" NETRW SETTINGS {{{
" Some commands to make netrw more bearable
let g:netrw_banner = 1       " Enable or disable Banner
let g:netrw_liststyle = 3    " Default Tree view
let g:netrw_browse_split = 3 " open files in a new tab
" let g:netrw_keepdir = 0      " Change working dir whilst browsing.
" I dont know if I want the above sometime it means I get all woobled.

" hiding dotfiles and python dunder files by default
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'.','.'^__.*__.*$' 

" Setting mappings for netrw when entering buffer named netrw, netrw
" apparently sets this local to the buffer so we need and autocmd to remap
" some of these jawns for us
augroup netrw_mapping
  autocmd!
	autocmd filetype netrw call NetrwMapping()
augroup END

" Keep track of last tab open to allow for a quick swapback in netrw
if !exists('g:lasttab')
  let g:lasttab = 1
endif
au TabLeave * let g:lasttab = tabpagenr()

" Put the mappings in this code block
function! NetrwMapping()
  " Open tree in same window on o
  noremap <buffer> o :Ntree<CR> 
  nmap <buffer> <C-o> ma:argdo tabnew<CR>
endfunction
""" END NETRW }}}
" }}}
set modelines=1
" vim:foldmethod=marker:foldlevel=0
