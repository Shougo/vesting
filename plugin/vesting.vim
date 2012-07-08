"=============================================================================
" FILE: vesting.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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

if exists('g:loaded_vesting')
  finish
elseif v:version < 702
  echoerr 'vesting does not work this version of Vim "' . v:version . '".'
  finish
endif

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

command! -nargs=+ Context
      \ call vesting#context(<q-args>)
command! -nargs=+ It
      \ call vesting#it(<q-args>)
command! -nargs=+ Should
      \ call vesting#should(<q-args>, eval(<q-args>))
command! -nargs=0 End
      \ call vesting#end()
command! Fin
      \ call vesting#fin


let g:loaded_vesting = 1

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: foldmethod=marker
