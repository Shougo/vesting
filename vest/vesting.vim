" Tests for vesting.

scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

Context Vesting.run()
  It checks true
    Should 1 == 1
    ShouldNot 1 == 0
    ShouldEqual 1, 1
    ShouldEqual 1, 0
    ShouldNotEqual 1, 0
  End

  It check is not true
    Should 1 == 1
    ShouldNot 1 == 0
    ShouldEqual 1, 1
    ShouldEqual 1, 0
    ShouldNotEqual 1, 0
  End

  P {'hoge'}

  throw 'hoge'
End

Fin

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

" vim:foldmethod=marker:fen:
