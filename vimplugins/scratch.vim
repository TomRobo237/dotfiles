" A quick Scratch buffer to be able to jot shit down.

" {{{ Scratch Buffer 
" Modified the scratch.vim plugin to suit needs.
" src: https://github.com/vim-scripts/scratch.vim/blob/master/plugin/scratch.vim
let ScratchBufferName = "__Scratch__"

" opening a new buffer function:
function! ScratchOpen(...)
  " Checking to see if there is already a buffer with the name
  let scr_buf = bufnr(g:ScratchBufferName)
  if scr_buf == -1
    if exists('a:1')
      exe "botright vsplit " . g:ScratchBufferName
    else
      exe "botright 10split " . g:ScratchBufferName
    endif
  else
    " Buffer already made, check if it is present in the current window
    let scr_winnum = bufwinnr(scr_buf)
    " If not -1, then that means its open somewhere, check that its the
    " current window or not.
    if scr_winnum == -1
      if exists('a:1')
        exe "vsplit +buffer" . scr_buf
      else
        exe "botright 10split +buffer" . scr_buf
      endif
    else
      if exists('a:1')
        exe scr_winnum . "wincmd w" 
      else 
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
command! ScratchVertical call ScratchOpen(1)
command! WipeScratch call ScratchWipe()
" }}}

