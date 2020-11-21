" Some quick git commands, TODO: Create scratch buffer to place all this into
" and dynamically load this, creating my own scratch.vim might be a good idea
" for this.
"
" I also use the gitgutter plugin from airblade, can be found at:
" https://github.com/airblade/vim-gitgutter
"
" There was probably a plugin that can do all this better. But hey.

" Toggle the checked branch for both git gutter and my git functions.
function! ChangeDiffBranch(branchname)
  let g:gitgutter_diff_base = a:branchname
  let g:gitdiff = a:branchname
endfunction 

" {{{ Git Scratch Buffer 
" Modified the scratch.vim plugin to suit needs.
" src: https://github.com/vim-scripts/scratch.vim/blob/master/plugin/scratch.vim
let GitScratchBufferName = "__GitScratch__"

" opening a new buffer function:
function! GitScratchOpen()
  " Checking to see if there is already a buffer with the name
  let git_scr_buf = bufnr(g:GitScratchBufferName)
  if git_scr_buf == -1
    exe "botright vnew " . g:GitScratchBufferName
  else
    " Buffer already made, check if it is present in the current window
    let git_scr_winnum = bufwinnr(git_scr_buf)
    " If not -1, then that means its open somewhere, check that its the
    " current window or not.
    if git_scr_winnum == -1
      exe "vsplit +buffer" . git_scr_buf
    else
      if winnr() != git_scr_winnum
        exe git_scr_winnum . "wincmd w"
      endif
    endif  
  endif
  set ft=scratch
endfunction

function! s:MarkScratch()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal buflisted
endfunction

autocmd BufNewFile __GitScratch__ call s:MarkScratch()

function! GitScratchRead(var)
  call GitScratchOpen()
  put =a:var
endfunction

function! GitScratchWipe()
  call GitScratchOpen()
  normal! gg"xdG
endfunction

function! GitScratchWipeAndRead(var)
  call GitScratchOpen()
  call GitScratchWipe()
  call GitScratchRead(a:var)
endfunction

function! GitScratchWipeReadAndRefocus(var)
  let curwin = winnr()
  call GitScratchWipeAndRead(a:var)
  exe curwin . "wincmd w"
endfunction

function! GitScratchWipeReadAndRefocusDiff(var)
  let curwin = winnr()
  call GitScratchWipeAndRead(a:var)
  set ft=gitcommit
  exe curwin . "wincmd w"
endfunction

function! GitScratchWipeReadCSV(var)
  call GitScratchWipeAndRead(a:var)
  normal ggdd
  set ft=csv
endfunction
" }}}

" {{{ GITGUTTER customizations
" Setting highlighting by default
let g:gitgutter_highlight_lines=1

" Setting default check branch to develop
call ChangeDiffBranch('master')

command! -nargs=1 GGCompare
  \ :call ChangeDiffBranch('<args>') | :GitGutter

" Quick maps for changing branch
" Am still hesitant about setting to d b/c may accidentally the whole thing
nmap <leader>dh :call ChangeDiffBranch('head')<CR>:GitGutter<CR>
nmap <leader>dv :call ChangeDiffBranch('develop')<CR>:GitGutter<CR>
nmap <leader>dm :call ChangeDiffBranch('master')<CR>:GitGutter<CR>

""" END GITGUTTER }}}

" {{{ My Git Commands
command! GFilenameDiff  
  \ let gitvar = system('git diff '.g:gitdiff.'...HEAD --name-only' 
  \ . ' --diff-filter=ACMRT | tee /tmp/filediff.txt') |
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

" Status incudes the above diff but I made that one a hsplit, this ones a
" vsplit
command! GStatus        
  \ let gitvar = system('git branch ;printf "\n"; git status ; printf "\n" ;' 
  \ . ' git diff ' . g:gitdiff . '...HEAD --name-only --diff-filter=ACMRT'  ) | 
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar 

command! -nargs=1 GCheckout
  \ let gitvar = system('git checkout <args>; git status') | 
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! -nargs=1 GCheckoutForce
  \ let gitvar = system('git checkout -f <args>; git status') | 
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! -nargs=1 GCheckoutNew
  \ let gitvar = system('git checkout -b <args>; git status; '
  \ . 'git push -u origin HEAD') | call GitScratchWipeReadAndRefocus(gitvar) | 
  \ unlet gitvar

command! GPull
	\ let gitvar = system('git pull ; git status') |
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! GPush
	\ let gitvar = system('git push ; git status') |
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! GAddCurr
	\ let gitvar = system('git add -v '. expand('%')) | 
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! -nargs=* -complete=file GAdd 
	\ let gitvar = system('git add -v <args>') | 
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! -nargs=1 GCommit
  \ let escaped = shellescape("<args>") |
	\ let gitvar = system('git commit -m '.escaped.';') | 
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar

command! GFetchDiff
  \ let gitvar = system('git fetch origin '.g:gitdiff.':'.g:gitdiff) |
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar 

command! StashStatus
  \ let gitvar = system('git stash list ; echo "Latest Diff: "' 
  \ . '; git stash show') | call GitScratchWipeReadAndRefocusDiff(gitvar) | 
  \ unlet gitvar 

command! -nargs=1 StashPush
  \ let gitvar = system('git stash push -m "<args>" ; git stash list') |
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar 

command! -nargs=1 StashPop
  \ let gitvar = system('git stash pop stash@{<args>}') |
  \ call GitScratchWipeReadAndRefocus(gitvar) | unlet gitvar 

command! DirtyCheck
  \ let gitvar = system('git diff head ' . expand('%')) |
  \ call GitScratchWipeReadAndRefocusDiff(gitvar) | unlet gitvar

command! DirtyCheck
  \ let gitvar = system('git diff head ' . expand('%')) |
  \ call GitScratchWipeReadAndRefocusDiff(gitvar) | unlet gitvar

command! DirtyCheckBranch
  \ let gitvar = system('git diff head') |
  \ call GitScratchWipeReadAndRefocusDiff(gitvar) | unlet gitvar

command! GBranchDiff    
  \ : tabnew __fulldiff-`uuidgen` |  :let gitvar = system('git diff ' 
  \ . g:gitdiff) | set bt=nofile | set ft=gitcommit | :put =gitvar | 
  \ : unlet gitvar | normal! gg<C-W>p

command! GDiff          
  \ let gitvar = system('git diff '.g:gitdiff.'...HEAD '.expand('%')) |
  \ call GitScratchWipeReadAndRefocusDiff(gitvar) | unlet gitvar 

command! GLogAbbrv
  \ let gitvar=system('printf "commit,auth,title,time\n";'
  \ . 'git log --pretty="format:%h , %an , %ar , %s" --abbrev-commit') |
  \ call GitScratchWipeReadCSV(gitvar) | unlet gitvar

command! -nargs=1 GDiffCommit 
  \ let gitvar=system('git diff <args> HEAD') | 
  \ call GitScratchWipeReadAndRefocusDiff(gitvar) | unlet gitvar
" }}}

" Adding creation of tags to a command so we can tag search and update as 
" needed.
command! Tags
  \ !cd $(git rev-parse --show-toplevel) && ctags -VR . --sort=yes
"
set modelines=1
" vim:foldmethod=marker:foldlevel=0
