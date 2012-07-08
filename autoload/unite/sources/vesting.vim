"=============================================================================
" FILE: vesting.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 08 Jul 2012.
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
      \}

function! s:source.gather_candidates(args, context)"{{{
  if empty(a:args)
    return []
  endif

  let dir = join(a:args, ':')
  let results = []
  for vest in split(glob(dir . '/vest/*.vim', 1), '\n')
    source `=vest`
    call add(results, vesting#get_result())
  endfor

  return map(results, "{
        \ 'word' : v:val,
        \ }
        \")
endfunction"}}}
function! s:source.complete(args, context, arglead, cmdline, cursorpos)"{{{
  return unite#sources#file#complete_directory(
        \ a:args, a:context, a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
