"=============================================================================
" FILE: vesting.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 08 Dec 2012.
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

function! s:define_commands() "{{{
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
        \     'file' : expand('<sfile>')}, 0) |
        \ catch |
        \   call vesting#error(
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}) |
        \ endtry
  command! -nargs=+ ShouldNot
        \ try |
        \   call vesting#should(eval(<q-args>), <q-args>,
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}, 1) |
        \ catch |
        \   call vesting#error(
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}) |
        \ endtry
  command! -nargs=+ ShouldEqual
        \ try |
        \   call vesting#should_equal(
        \     eval('[' . <q-args> . ']'), '['.<q-args>.']',
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}, 0) |
        \ catch |
        \   call vesting#error(
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}) |
        \ endtry
  command! -nargs=+ ShouldNotEqual
        \ try |
        \   call vesting#should_equal(
        \     eval('[' . <q-args> . ']'), '['.<q-args>.']',
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}, 1) |
        \ catch |
        \   call vesting#error(
        \     { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')}) |
        \ endtry
  command! -nargs=0 End
        \ call vesting#end(
        \   { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')})
  command! -nargs=0 Fin
        \ call vesting#fin(
        \   { 'linenr' : expand('<slnum>'),
        \     'file' : expand('<sfile>')})

  command! -nargs=+ -complete=expression P
        \ echomsg string(<args>)
endfunction"}}}
function! s:undefine_commands() "{{{
  delcommand! Context
  delcommand! It
  delcommand! Should
  delcommand! ShouldNot
  delcommand! ShouldEqual
  delcommand! ShouldNotEqual
  delcommand! Raises
  delcommand! End
  delcommand! Fin
  delcommand! P
endfunction"}}}

function! vesting#load() "{{{
  call s:define_commands()
endfunction"}}}

function! vesting#clean() "{{{
  call s:undefine_commands()
endfunction"}}}

function! vesting#init() "{{{
  let s:results = {}
  let s:errored = 0
  let s:context_stack = [
        \ { 'mode' : 'context', 'args' : 'init_context',
        \   'linenr' : expand('<slnum>'),
        \   'file' : expand('<sfile>')},
        \ { 'mode' : 'it', 'args' : 'init_it',
        \   'linenr' : expand('<slnum>'),
        \   'file' : expand('<sfile>')},
        \ ]
endfunction"}}}

function! vesting#should(result, cond, context, is_not) "{{{
  let it = s:context_stack[-1].args
  let context = s:context_stack[-2].args
  if !has_key(s:results, context)
    let s:results[context] = []
  endif

  let result = a:result
  if a:is_not
    let result = !result
  endif
  let text = result ? '[OK]    .' :
        \ printf('[Fail]  %s:%d: It %s : %s',
        \ a:context.file, a:context.linenr, it, a:cond)

  call add(s:results[context],
        \ { 'linenr' : a:context.linenr,
        \   'file' : a:context.file,
        \   'text' : text })
endfunction"}}}

function! vesting#should_equal(result, cond, context, is_not) "{{{
  let lhs = a:result[0]
  let rhs = a:result[1]

  let it = s:context_stack[-1].args
  let context = s:context_stack[-2].args
  if !has_key(s:results, context)
    let s:results[context] = []
  endif

  let result = lhs ==# rhs
  if a:is_not
    let result = !result
  endif
  let text = result ? '[OK]    .' :
        \ printf('[Fail]  %s:%d: It %s : %s %s %s',
        \   a:context.file, a:context.linenr, it,
        \   string(a:result[0]), (a:is_not ? '==' : '!='),
        \   string(a:result[1]))

  call add(s:results[context],
        \ { 'linenr' : a:context.linenr,
        \   'file' : a:context.file,
        \   'text' : text })
endfunction"}}}

function! vesting#error(context) "{{{
  let context = s:context_stack[-2].args
  if !has_key(s:results, context)
    let s:results[context] = []
  endif

  let text = printf('[Error] %s:%d: %s : %s',
        \ a:context.file, a:context.linenr,
        \ v:throwpoint, v:exception)
  call add(s:results[context],
        \ { 'linenr' : a:context.linenr,
        \   'file' : a:context.file,
        \   'text' : text })
endfunction"}}}

function! vesting#context(args, context) "{{{
  let context = extend(copy(a:context),
        \ {'mode' : 'context', 'args' : a:args,
        \ })
  call add(s:context_stack, context)
endfunction"}}}

function! vesting#it(args, context) "{{{
  let context = extend(copy(a:context),
        \ {'mode' : 'it', 'args' : a:args,
        \ })
  call add(s:context_stack, context)
endfunction"}}}

function! vesting#end(context) "{{{
  call remove(s:context_stack, -1)
  redraw!
endfunction"}}}

function! vesting#fin(context)
endfunction

function! vesting#get_result() "{{{
  return s:results
endfunction"}}}

function! vesting#get_context() "{{{
  return s:context_stack[-1]
endfunction"}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: foldmethod=marker
