"=============================================================================
" FILE: junkfile.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 1.0, for Vim 7.2
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let g:junkfile#directory =
      \ get(g:, 'junkfile#directory', $HOME . '/.cache/junkfile')
let g:junkfile#edit_command =
      \ get(g:, 'junkfile#edit_command', 'edit')

function! junkfile#open(prefix, ...) "{{{
  let postfix = get(a:000, 0, '')
  let filename = postfix == '' ?
        \ input('Junk Code: ', a:prefix) : a:prefix . postfix

  if filename != ''
    call junkfile#_open(filename)
  endif
endfunction"}}}

function! junkfile#open_immediately(filename) "{{{
  call junkfile#_open(a:filename)
endfunction"}}}

function! junkfile#_open(filename)
  let filename = g:junkfile#directory . strftime('/%Y/%m/') . a:filename
  let junk_dir = fnamemodify(filename, ':h')
  if !isdirectory(junk_dir)
    call mkdir(junk_dir, 'p')
  endif

  execute g:junkfile#edit_command fnameescape(filename)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
