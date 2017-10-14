"=============================================================================
" FILE: junkfile.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" License: MIT license
"=============================================================================

if exists('g:loaded_junkfile')
  finish
endif

command! -range -nargs=? JunkfileOpen <line1>,<line2>call junkfile#open(
      \ strftime('%Y-%m-%d-%H%M%S.'), <q-args>)

let g:loaded_junkfile = 1
