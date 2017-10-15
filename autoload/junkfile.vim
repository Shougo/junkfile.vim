"=============================================================================
" FILE: junkfile.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

let g:junkfile#directory =
      \ get(g:, 'junkfile#directory',
      \  expand($XDG_CACHE_HOME != '' ?
      \   $XDG_CACHE_HOME . '/junkfile' : '~/.cache/junkfile'))
let g:junkfile#edit_command =
      \ get(g:, 'junkfile#edit_command', 'edit')

function! junkfile#init() abort
endfunction

function! junkfile#open(prefix, ...) range abort
  let use_range = a:lastline - a:firstline > 0
  if use_range
    let saved_lines = getline(a:firstline, a:lastline)
  endif

  let postfix = get(a:000, 0, '')
  let postfix_candidate = !use_range || postfix != '' ?
        \ '' : expand('%:e')
  let filename = postfix == '' ?
        \ input('Junk Code: ', a:prefix . postfix_candidate) : a:prefix . postfix

  if filename != ''
    call junkfile#_open(filename)
  endif

  if use_range
    call append(0, saved_lines)
    "not sure why but an extra blank line seems to always be added
    silent! normal "_dd
    write
  endif

endfunction

function! junkfile#open_immediately(filename) abort
  call junkfile#_open(a:filename)
endfunction

function! junkfile#_open(filename) abort
  let filename = g:junkfile#directory . strftime('/%Y/%m/') . a:filename
  let junk_dir = fnamemodify(filename, ':h')
  if !isdirectory(junk_dir)
    call mkdir(junk_dir, 'p')
  endif

  execute g:junkfile#edit_command fnameescape(filename)
endfunction
