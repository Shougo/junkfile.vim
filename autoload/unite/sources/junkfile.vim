"=============================================================================
" FILE: junkfile.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 Feb 2013.
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
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#junkfile#define() "{{{
  return [s:source_junkfile, s:source_junkfile_new]
endfunction"}}}

let s:source_junkfile = {
      \ 'name' : 'junkfile',
      \ 'description' : 'candidates from junkfiles',
      \ 'max_candidates' : 30,
      \ }

function! s:source_junkfile.gather_candidates(args, context) "{{{
  let _ = map(filter(split(glob(g:junkfile#directory . '/**'), '\n'),
        \  'filereadable(v:val)'), "{
        \ 'word' : fnamemodify(v:val, ':t'),
        \ 'kind' : 'file',
        \ 'action__path' : unite#util#substitute_path_separator(v:val),
        \ }
        \")

  return reverse(_)
endfunction"}}}

let s:source_junkfile_new = {
      \ 'name' : 'junkfile/new',
      \ 'description' : 'new candidates in junkfile',
      \ }

function! s:source_junkfile_new.change_candidates(args, context) "{{{
  let junk_dir = g:junkfile#directory . strftime('/%Y/%m')
  if !isdirectory(junk_dir)
    call mkdir(junk_dir, 'p')
  endif

  let _ = map([junk_dir . strftime('/%Y-%m-%d-%H%M.') . a:context.input], "{
        \ 'word' : fnamemodify(v:val, ':t'),
        \ 'kind' : 'file',
        \ 'action__path' : unite#util#substitute_path_separator(v:val),
        \ }
        \")

  return _
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
