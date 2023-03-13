" Run fmt
function! RunFmt()
	execute "silent !zig fmt %"
	redraw!
endfunction
nnoremap <buffer> <localleader>f :call RunFmt()<CR>
