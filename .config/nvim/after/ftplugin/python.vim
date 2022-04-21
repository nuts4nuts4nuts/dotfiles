" Run mtgeblack on the current file BB_SPECIFIC
function! RunBlack()
	execute "silent !mtgeblack %"
	redraw!
endfunction
nnoremap <buffer> <localleader>f :call RunBlack()<CR>

" Don't hard wrap lines despite what polyglot (??) might say
set formatoptions-=t

" :make on a py file calls pylint and passes issues to quickfix
set makeprg=pylint\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ {msg}\"\ %:p
set errorformat=%f:%l:\ %m
