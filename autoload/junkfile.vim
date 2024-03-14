let s:default_directory = ($XDG_CACHE_HOME != '' ?
      \   $XDG_CACHE_HOME .. '/junkfile' : '~/.cache/junkfile')->expand(1)
let g:junkfile#directory =
      \ g:->get('junkfile#directory', s:default_directory)
let g:junkfile#edit_command =
      \ g:->get('junkfile#edit_command', 'edit')

function junkfile#init() abort
endfunction

function junkfile#open(prefix, ...) range abort
  const use_range = a:lastline - a:firstline > 0
  if use_range
    let saved_lines = a:firstline->getline(a:lastline)
  endif

  const postfix = a:000->get(0, '')
  let postfix_candidate = !use_range || postfix != '' ? '' : '%:e'->expand()
  let filename = postfix == ''
        \ ? 'Junk Code: '->input(a:prefix .. postfix_candidate)
        \ : a:prefix .. postfix

  if filename !=# ''
    call junkfile#_open(filename)
  endif

  if use_range
    call append(0, saved_lines)
    " NOTE: not sure why but an extra blank line seems to always be added
    silent! normal "_dd
    call deletebufline(bufnr(), '.'->line())

    write
  endif

endfunction

function junkfile#open_immediately(filename) abort
  call junkfile#_open(a:filename)
endfunction

function junkfile#_open(filename) abort
  let filename = g:junkfile#directory .. '/%Y/%m/'->strftime() .. a:filename
  let junk_dir = filename->fnamemodify(':h')
  if !junk_dir->isdirectory()
    call mkdir(junk_dir, 'p')
  endif

  execute g:junkfile#edit_command filename->fnameescape()
endfunction
