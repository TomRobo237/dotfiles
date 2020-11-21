
" A quick Scratch buffer to be able to jot shit down.

" {{{ Scratch Buffer 
" Modified the scratch.vim plugin to suit needs.
" src: https://github.com/vim-scripts/scratch.vim/blob/master/plugin/scratch.vim
let LintBufferName = "__lint__"

" opening a new buffer function:
function! LintOpen()
  " Checking to see if there is already a buffer with the name
  let scr_buf = bufnr(g:LintBufferName)
  if scr_buf == -1
    exe "botright 10split " . g:LintBufferName
  else
    " Buffer already made, check if it is present in the current window
    let scr_winnum = bufwinnr(scr_buf)
    " If not -1, then that means its open somewhere, check that its the
    " current window or not.
    if scr_winnum == -1
      exe "botright 10split +buffer" . scr_buf
    else
      if winnr() != scr_winnum
        exe scr_winnum . "wincmd w"
      endif
    endif  
  endif
endfunction

function! s:MarkLint()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal buflisted
endfunction

autocmd BufNewFile __lint__ call s:MarkLint()

function! LintRead(var)
  call LintOpen()
  put =a:var
endfunction

function! LintWipe()
  call LintOpen()
  normal! gg"xdG
endfunction

function! LintWipeAndRead(var)
  call LintOpen()
  call LintWipe()
  call LintRead(a:var)
endfunction

function! LintWipeReadAndRefocus(var)
  let curwin = winnr()
  call LintWipeAndRead(a:var)
  exe curwin . "wincmd w"
endfunction
" }}}

" IF GIT THEN GET PYLINT RC FILE {{{
function! FindPylintRc()
  let rcfile = ''
  let isgit = Strip(system('git rev-parse --is-inside-work-tree 2>/dev/null'))
  if isgit == 'true'
    let projpath = trim(system('git rev-parse --show-toplevel'))
    if filereadable(projpath . '/.pylintrc')
      let rcfile = projpath . '/.pylintrc'
    endif
  endif
  if rcfile == ''
    return rcfile
  else
    return '--rcfile=' . rcfile
  endif
endfunction
" }}}

" LINTING COMMANDS {{{
command! PyLintFile           
  \ let lint = system('pylint '. FindPylintRc() . ' ' . expand('%')) | 
  \ call LintWipeReadAndRefocus(lint) | unlet lint

command! PhpLint             
  \ let lint = system('php -l ' . expand('%')) | 
  \ call LintWipeReadAndRefocus(lint) | unlet lint

command! BashLint
  \ let lint = system('checkbashisms ' . expand('%')) | 
  \ call LintWipeReadAndRefocus(lint) | unlet lint
 
command! ShellLint
  \ let lint = system('shellcheck -x ' . expand('%')) | 
  \ call LintWipeReadAndRefocus(lint) | unlet lint

" }}} END LINT
