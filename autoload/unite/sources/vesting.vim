"=============================================================================
" FILE: vesting.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 28 Oct 2012.
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
  let vests = filter(a:args[1:], "v:val != ''")
  let dir = get(a:args, 0, '.')
  let all_vests = map(split(glob(dir . '/vest/*.vim', 1), '\n'),
          \ "fnamemodify(v:val, ':t:r')")
  if empty(all_vests)
    " Returns vesting directories.
    return map(unite#util#uniq(
          \ map(split(glob(dir . '/*/vest/*.vim', 1), '\n'),
          \   "fnamemodify(v:val, ':h:h:t')")), "{
          \   'word' : v:val,
          \   'kind' : 'source',
          \   'action__source_name' : 'vesting',
          \   'action__source_args' : [v:val],
          \ }")
  endif

  if index(vests, '!') >= 0
    " Use all vesting scripts.
    let vests = all_vests
  elseif empty(vests)
    " Selects vesting scripts.
    return map(all_vests, "{
          \ 'word' : v:val,
          \ 'kind' : 'source',
          \ 'action__source_name' : 'vesting',
          \ 'action__source_args' : [dir, v:val],
          \ }")
  endif

  let results = []
  let candidates = []

  for vest in map(vests, "dir.'/vest/'.v:val.'.vim'")
    if !filereadable(vest)
      continue
    endif

    call vesting#init()

    call add(candidates,
          \ { 'word' : '[Vest]  ' . vest, 'is_dummy' : 1})

    try
      source `=vest`
    catch
      let context = vesting#get_context()
      if v:throwpoint =~ 'line \d\+'
        let context.linenr =
              \ matchstr(v:throwpoint, 'line \zs\d\+')
      endif

      call vesting#error(context)
    endtry

    let results = []

    let [ok, fail, error] = [0, 0, 0]
    for result  in values(vesting#get_result())
      let results += result

      let ok += len(filter(copy(result),
            \ "v:val.text =~# '^\\[OK\\]'"))
      let fail += len(filter(copy(result),
            \ "v:val.text =~# '^\\[Fail\\]'"))
      let error += len(filter(copy(result),
            \ "v:val.text =~# '^\\[Error\\]'"))
    endfor

    call unite#print_source_message(
          \ printf('%s: OK = %s, Fail = %s, Error = %s',
          \   vest, ok, fail, error),
          \ s:source.name)

    let candidates += map(results, "{
          \ 'word': v:val.text,
          \ 'kind': 'jump_list',
          \ 'is_multiline' : 1,
          \ 'action__path': v:val.file,
          \ 'action__line': v:val.linenr,
          \ 'action__text': v:val.text,
          \ }
          \")
  endfor

  return candidates
endfunction"}}}
function! s:source.complete(args, context, arglead, cmdline, cursorpos)"{{{
  if len(a:args) <= 1
    return unite#sources#file#complete_directory(
          \ a:args, a:context, a:arglead, a:cmdline, a:cursorpos)
  else
    let dir = a:args[0]
    return map(split(glob(dir . '/vest/'
          \ . a:args[-1] . '*.vim', 1), '\n'),
          \ "fnamemodify(v:val, ':t:r')")
  endif
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
