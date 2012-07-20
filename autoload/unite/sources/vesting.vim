"=============================================================================
" FILE: vesting.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 20 Jul 2012.
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

function! unite#sources#vesting#define()"{{{
  call vesting#load()
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vesting',
      \ 'description' : 'test candidate from vesting',
      \ 'hooks' : {},
      \ 'syntax' : 'uniteSource__Vesting',
      \}

function! s:source.hooks.on_init(args, context)"{{{
  call vesting#load()
endfunction"}}}
function! s:source.hooks.on_syntax(args, context)"{{{
  syntax match uniteSource__VestingError /.*:.*$/
        \ contained containedin=uniteSource__Vesting
  highlight default link uniteSource__VestingError ErrorMsg

  syntax match uniteSource__VestingFilename /\[Vest\].*$/
        \ contained containedin=uniteSource__Vesting
  highlight default link uniteSource__VestingFilename Comment
endfunction"}}}
function! s:source.gather_candidates(args, context)"{{{
  if empty(a:args)
    return []
  endif

  let dir = join(a:args, ':')
  let results = []
  let candidates = []

  for vest in split(glob(dir . '/vest/*.vim', 1), '\n')
    call vesting#init()

    call add(candidates, { 'word' : '[Vest]  ' . vest, 'is_dummy' : 1})

    try
      source `=vest`
    catch
      call vesting#error(vesting#get_context())
    endtry

    let results = []

    for result  in values(vesting#get_result())
      let results += result
    endfor

    let candidates += map(results, "{
          \ 'word': v:val.text,
          \ 'kind': 'jump_list',
          \ 'action__path': v:val.file,
          \ 'action__line': v:val.linenr,
          \ 'action__text': v:val.text,
          \ }
          \")
  endfor

  return candidates
endfunction"}}}
function! s:source.complete(args, context, arglead, cmdline, cursorpos)"{{{
  return unite#sources#file#complete_directory(
        \ a:args, a:context, a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
