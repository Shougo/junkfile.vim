"=============================================================================
" FILE: junkfile.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" License: MIT license
"=============================================================================

function! unite#sources#junkfile#define() abort
  return [s:source_junkfile, s:source_junkfile_new]
endfunction

let s:source_junkfile = {
      \ 'name' : 'junkfile',
      \ 'description' : 'candidates from junkfiles',
      \ 'max_candidates' : 30,
      \ 'action_table' : {},
      \ }

function! s:source_junkfile.gather_candidates(args, context) abort
  let _ = map(filter(split(glob(g:junkfile#directory . '/**'), '\n'),
        \  'filereadable(v:val)'), "{
        \ 'word' : fnamemodify(v:val, ':t'),
        \ 'kind' : 'file',
        \ 'action__path' : unite#util#substitute_path_separator(v:val),
        \ }
        \")

  return unite#util#sort_by(_, '-getftime(v:val.action__path)')
endfunction

let s:source_junkfile_new = {
      \ 'name' : 'junkfile/new',
      \ 'description' : 'new candidates in junkfile',
      \ 'action_table' : {},
      \ }

function! s:source_junkfile_new.change_candidates(args, context) abort
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
endfunction

let s:source_junkfile.action_table.delete = {
      \ 'description' : 'delete files',
      \ 'is_quit' : 0,
      \ 'is_invalidate_cache' : 1,
      \ 'is_selectable' : 1,
      \}
function! s:source_junkfile.action_table.delete.func(candidates) abort
  if unite#util#input_yesno('Really force delete files?')
    for candidate in a:candidates
      call delete(candidate.action__path)
    endfor
  endif
endfunction

let s:source_junkfile.action_table.unite__new_candidate = {
      \ 'description' : 'create a new junkfile',
      \ 'is_listed' : 0,
      \}
function! s:source_junkfile.action_table.unite__new_candidate.func(candidate) abort
  call junkfile#open(strftime('%Y-%m-%d-%H%M%S.'))
endfunction

let s:source_junkfile_new.action_table.unite__new_candidate =
      \ deepcopy(s:source_junkfile.action_table.unite__new_candidate)
