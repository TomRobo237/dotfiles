
" TABLINE {{{
" UGH I JUST WANT TAB NUMBERS IN THE LINE TO USE #gt ALL EZPZ... this got out
" of hand real fast.
set tabline=%!MyTabLine()

" This part is from :help setting-tabline that I've fuddled with to make it
" work the way I want to. Bending it to my will.
function MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " set the tab page number
    let s .= (i + 1) . ':'
    " the label is made by MyTabLabel() below.
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor
  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  return s
endfunction

" Once again more from :help setting-tabline, but theres a bunch more that I
" monkey'ed together.
function MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let myname = bufname(buflist[winnr - 1])
  " If its a netrw tab, dont care just list as explorer
  if myname =~ 'NetrwTreeListing'
    let myname = 'Explorer'
  else 
    " Change path to be relative to current folder or home.
    let myname = fnamemodify(myname, ':~:.')
    " sometimes the pathnames are too long and need squashing.
    if len(myname) > 25
      let fol = split(myname, '/')
      let fname = fol[len(fol) - 1]
      let retfol = []
      " iterate through all but last item, thats the filename,
      for i in fol[:-2]
        let retfol = retfol + [i[0]]
      endfor
      if len(retfol) == 0
        let myname = fname
      else
        let myname = join(retfol, '/') . '/' . fname
      endif
    endif
  endif
  return myname
endfunction
""" END TABLINE }}}
