"=============================================================================
" FILE: vesting.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 18 Jul 2012.
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

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

command! -nargs=+ Context
      \ call vesting#context(<q-args>)
command! -nargs=+ It
      \ call vesting#it(<q-args>)
command! -nargs=+ Should
      \ try |
      \   call vesting#should(eval(<q-args>), <q-args>,
      \    { 'linenr' : expand('<slnum>'),  'file' : expand('<sfile>') }, 0) |
      \ catch |
      \   call vesting#should('', '',
      \    { 'linenr' : expand('<slnum>'),  'file' : expand('<sfile>') }, 1) |
      \ endtry
command! -nargs=0 End
      \ call vesting#end()
command! -nargs=0 Fin
      \ call vesting#fin()

function! vesting#load()"{{{
  let s:results = {}
  let s:context_stack = []
endfunction"}}}

function! vesting#should(result, cond, context, is_error)"{{{
  " FIXME: validate
  let it = s:context_stack[-1][1]
  let context = s:context_stack[-2][1]
  if !has_key(s:results, context)
    let s:results[context] = []
  endif

  if a:is_error
    let text = printf('[Error] %s:%d: %s : %s',
        \ a:context.file, a:context.linenr, v:throwpoint, v:exception)
  else
    let text = a:result ? '[OK]    .' :
          \ printf('[Fail]  %s:%d: It %s : %s',
          \ a:context.file, a:context.linenr, it, a:cond)
  endif

  call add(s:results[context],
        \ { 'linenr' : a:context.linenr, 'file' : a:context.file,
        \   'text' : text })
endfunction"}}}

function! vesting#context(args)
  call add(s:context_stack, ['c', a:args])
endfunction

function! vesting#it(args)
  call add(s:context_stack, ['i', a:args])
endfunction

function! vesting#end()
  call remove(s:context_stack, -1)
  redraw!
endfunction

function! vesting#fin()
endfunction

function! vesting#get_result()"{{{
  return s:results
endfunction"}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: foldmethod=marker
