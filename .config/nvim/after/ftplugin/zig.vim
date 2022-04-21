" Run mtgeblack on the current file BB_SPECIFIC
function! RunFmt()
	execute "silent !zig fmt %"
	redraw!
endfunction
nnoremap <buffer> <localleader>f :call RunFmt()<CR>
