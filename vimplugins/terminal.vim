" A terminal buffer that can be pulled up with a function.

" {{{ Terminal Buffer 
" Modified the scratch.vim plugin to suit needs.
" src: https://github.com/vim-scripts/scratch.vim/blob/master/plugin/scratch.vim

" opening a new buffer function:
function! TermOpen(cmdname)
  " Checking to see if there is already a buffer with the name
  let scr_buf = bufnr('!' . a:cmdname)
  if scr_buf == -1
    exe "below terminal " . a:cmdname 
  else
    " Buffer already made, check if it is present in the current window
    let scr_winnum = bufwinnr(scr_buf)
    " If not -1, then that means its open somewhere, check that its the
    " current window or not.
    if scr_winnum == -1
      exe "below split +buffer" . scr_buf
    else
      if winnr() != scr_winnum
        exe scr_winnum . "wincmd w"
      endif
    endif  
  endif
endfunction

function! s:MarkScratch()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal buflisted
endfunction

autocmd BufNewFile __Scratch__ call s:MarkScratch()

function! ScratchRead(var)
  call ScratchOpen()
  put =a:var
endfunction

function! ScratchWipe()
  call ScratchOpen()
  normal! gg"xdG
endfunction

function! ScratchWipeAndRead(var)
  call ScratchOpen()
  call ScratchWipe()
  call ScratchRead(a:var)
endfunction

function! ScratchWipeReadAndRefocus(var)
  let curwin = winnr()
  call ScratchWipeAndRead(a:var)
  exe curwin . "wincmd w"
endfunction

command! Scratch call ScratchOpen()
" }}}

