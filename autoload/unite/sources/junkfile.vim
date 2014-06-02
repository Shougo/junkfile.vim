"=============================================================================
" FILE: junkfile.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
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
      \ 'action_table' : {},
      \ }

function! s:source_junkfile.gather_candidates(args, context) "{{{
  let _ = map(filter(split(glob(g:junkfile#directory . '/**'), '\n'),
        \  'filereadable(v:val)'), "{
        \ 'word' : fnamemodify(v:val, ':t'),
        \ 'kind' : 'file',
        \ 'action__path' : unite#util#substitute_path_separator(v:val),
        \ }
        \")

  return unite#util#sort_by(_, '-getftime(v:val.action__path)')
endfunction"}}}

let s:source_junkfile_new = {
      \ 'name' : 'junkfile/new',
      \ 'description' : 'new candidates in junkfile',
      \ 'action_table' : {},
      \ }

function! s:source_junkfile_new.change_candidates(args, context) "{{{
  let junk_dir = g:junkfile#directory . strftime('/%Y/%m')
  if !isdirectory(junk_dir)
    call mkdir(junk_dir, 'p')
  endif

  let filename = unite#util#substitute_path_separator(
        \ junk_dir . strftime('/%Y-%m-%d-%H%M%S.') . a:context.input)
  if filereadable(filename)
    return []
  endif

  let _ = map([filename], "{
        \ 'word' : fnamemodify(v:val, ':t'),
        \ 'abbr' : '[new file] ' . fnamemodify(v:val, ':t'),
        \ 'kind' : 'file',
        \ 'action__path' : v:val,
        \ }
        \")

  return _
endfunction"}}}

let s:source_junkfile.action_table.delete = {
      \ 'description' : 'delete files',
      \ 'is_quit' : 0,
      \ 'is_invalidate_cache' : 1,
      \ 'is_selectable' : 1,
      \}
function! s:source_junkfile.action_table.delete.func(candidates) "{{{
  if unite#util#input_yesno('Really force delete files?')
    for candidate in a:candidates
      call delete(candidate.action__path)
    endfor
  endif
endfunction"}}}

let s:source_junkfile.action_table.unite__new_candidate = {
      \ 'description' : 'create a new junkfile',
      \ 'is_listed' : 0,
      \}
function! s:source_junkfile.action_table.unite__new_candidate.func(candidate) "{{{
  call junkfile#open(strftime('%Y-%m-%d-%H%M%S.'))
endfunction"}}}

let s:source_junkfile_new.action_table.unite__new_candidate =
      \ deepcopy(s:source_junkfile.action_table.unite__new_candidate)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
