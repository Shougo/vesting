"=============================================================================
" FILE: vesting.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

command! -nargs=+ Context
      \ call vesting#context(<q-args>,
      \   { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')})
command! -nargs=+ It
      \ call vesting#it(<q-args>,
      \   { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')})
command! -nargs=+ Should
      \ try |
      \   call vesting#should(eval(<q-args>), <q-args>,
      \     { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')}, 0, 0) |
      \ catch |
      \   call vesting#should('', '',
      \     { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')}, 1, 0) |
      \ endtry
command! -nargs=+ ShouldNot
      \ try |
      \   call vesting#should(eval(<q-args>), <q-args>,
      \     { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')}, 0, 1) |
      \ catch |
      \   call vesting#should('', '',
      \     { 'linenr' : expand('<slnum>'),
      \       'file' : expand('<sfile>')}, 1, 1) |
      \ endtry
command! -nargs=+ Raises
command! -nargs=0 End
      \ call vesting#end(
      \   { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')})
command! -nargs=0 Fin
      \ call vesting#fin(
      \   { 'linenr' : expand('<slnum>'),
      \     'file' : expand('<sfile>')})

function! vesting#load()"{{{
endfunction"}}}

function! vesting#init()"{{{
  let s:results = {}
  let s:context_stack = [
        \ { 'mode' : '', 'args' : '',
        \   'linenr' : expand('<slnum>'), 'file' : expand('<sfile>')}]
endfunction"}}}

function! vesting#should(result, cond, context, is_error, is_not)"{{{
  let it = s:context_stack[-1].args
  let context = s:context_stack[-2].args
  if !has_key(s:results, context)
    let s:results[context] = []
  endif

  if a:is_error
    let text = printf('[Error] %s:%d: %s : %s',
        \ a:context.file, a:context.linenr, v:throwpoint, v:exception)
  else
    let result = a:result
    if a:is_not
      let result = !result
    endif
    let text = result ? '[OK]    .' :
          \ printf('[Fail]  %s:%d: It %s : %s',
          \ a:context.file, a:context.linenr, it, a:cond)
  endif

  call add(s:results[context],
        \ { 'linenr' : a:context.linenr, 'file' : a:context.file,
        \   'text' : text })
endfunction"}}}

function! vesting#context(args, context)"{{{
  let context = extend(copy(a:context),
        \ {'mode' : 'context', 'args' : a:args})
  call add(s:context_stack, context)
endfunction"}}}

function! vesting#it(args, context)"{{{
  let context = extend(copy(a:context),
        \ {'mode' : 'it', 'args' : a:args})
  call add(s:context_stack, context)
endfunction"}}}

function! vesting#end(context)"{{{
  call remove(s:context_stack, -1)
  redraw!
endfunction"}}}

function! vesting#fin(context)
endfunction

function! vesting#get_result()"{{{
  return s:results
endfunction"}}}

function! vesting#get_context()"{{{
  return s:context_stack[-1]
endfunction"}}}

function! s:get_default_context()"{{{
  return 
endfunction"}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: foldmethod=marker
