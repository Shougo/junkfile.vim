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

function! junkfile#open(prefix, ...) abort
  let postfix = get(a:000, 0, '')
  let filename = postfix == '' ?
        \ input('Junk Code: ', a:prefix) : a:prefix . postfix

  if filename != ''
    call junkfile#_open(filename)
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
