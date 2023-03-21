" Plugins
call plug#begin()
" Tim Pope
Plug 'tpope/vim-surround'                                   " More functionality for changing text surrounded by stuff
Plug 'tpope/vim-fugitive'                                   " Doing git stuff from vim
Plug 'tpope/vim-repeat'                                     " Make . work for some plugin action too (by default surround, speeddating, unimpaired, easyclip)
Plug 'tpope/vim-unimpaired'                                 " Expand the mappings for [] movements
Plug 'tpope/vim-sensible'                                   " Sensible defaults, replacing a lot of my settings
Plug 'tpope/vim-commentary'                                 " Comment with gc
" Misc
Plug 'sheerun/vim-polyglot'                                 " Support for lots of languages
Plug 'ludovicchabant/vim-gutentags'                         " Automated tag generation
Plug 'romainl/vim-cool'                                     " Better hlsearch behavior
Plug 'romainl/vim-qf'                                       " Tame the quickfix menu
Plug 'yssl/QFEnter'                                         " Open quickfix item in last focused window
" nvim stuff
Plug 'nvim-lua/plenary.nvim'                                " Some lua stuff
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }    " Fuzzy find
Plug 'neovim/nvim-lspconfig'                                " lspconfig
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Sit on a tree to understand it better
Plug 'nvim-treesitter/playground'
call plug#end()

"" FUNCTIONS
" Open the current buffer in a new tab and call git status
function! GS()
	tab split
	Git
	resize 15
endfunction
command! GS call GS()

" Set upstream branch and push
function! GP()
	let branch_name = FugitiveHead()
	execute "Git push --set-upstream origin " . branch_name
endfunction
command! GP call GP()

" Put current file and linenum into anonymous register
command! YankLinenum redir @" | echon expand('%:p')':'line('.') | redir END
command! YL YankLinenum

" When using `dd` in the quickfix list, remove the item from the quickfix list.
function! RemoveQFItem()
	let curqfidx = line('.') - 1
	let qfall = getqflist()
	call remove(qfall, curqfidx)
	call setqflist(qfall, 'r')
	execute curqfidx + 1 . "cfirst"
	:copen
endfunction
:command! RemoveQFItem :call RemoveQFItem()

" Use map <buffer> to only map dd in the quickfix window. Requires +localmap
autocmd FileType qf map <buffer> dd :RemoveQFItem<CR>

function! Leap(forwards) " TODO: Make this a plugin
	let l:jump_list_info = getjumplist()
	let l:current_jump = l:jump_list_info[1]

	let l:previous_jumps = l:jump_list_info[0][:l:current_jump - 1]
	let l:next_jumps = l:jump_list_info[0][l:current_jump + 1:]
	let l:current_buffer = bufnr('%')

	let l:candidate_jumps = (a:forwards ? l:next_jumps : reverse(l:previous_jumps))
	" There's got to be a more elegant way to do this but I'm a noob
	let l:jumps = 0
	for i in l:candidate_jumps
		let l:jumps += 1
		if i['bufnr'] != l:current_buffer
			execute "normal! ".l:jumps.(a:forwards ? "\<C-i>" : "\<C-o>")
			return
		endif
	endfor

	" If we haven't jumped by this point that means all the candidate jumps are in the same buffer
	" In that case we still want to jump as far as possible
	execute "normal! ".max([1, len(l:candidate_jumps)]).(a:forwards ? "\<C-i>" : "\<C-o>")
endfunction

" lcd to the directory of the current buffer
command! LCD lcd %:p:h
" delete the current buffer, leaving the previous buffer in its place
command! -bang BD buffer #<bar>bdelete<bang> #

" Save the current buffer and source it (for vimrc files and snippets)
augroup vim_commands
	autocmd!
	autocmd BufEnter *.vim command! W w | so %
	autocmd BufEnter vimrc command! W w | so %
	" autocmd BufEnter *.snippets command! W w | call UltiSnips#RefreshSnippets()
augroup END

" Rename the current buffer
command! -complete=file -nargs=1 Rename saveas %:h/<args> | !rm #

function! QuickFix_Toggle()
	for i in range(1, winnr('$'))
		let bnum = winbufnr(i)
		if getbufvar(bnum, '&buftype') == 'quickfix'
			cclose
			return
		endif
	endfor
	copen
endfunction

"" SETTINGS
" Disable bells, they're particularly annoying with Alt- ESC method
set noeb vb t_vb=

" Cool colors
set termguicolors

" Desert, baby
colorscheme desert
set background=dark

" Search, all lower = insensitive, any upper = sensitive
set ignorecase
set smartcase
set infercase
" highlight searches
set hlsearch
" default to utf-8 encoding
set encoding=utf-8
" hide buffers that are unsaved
set hidden
" disable annoying sticky comments
set formatoptions-=cro
set wildmenu
set wildmode=list:longest,full
" wildcharm does the same thing as <Tab>, but can be used in mapping where <Tab> doesn't work
set wildcharm=<C-z>
" make the mouse work in console vim
set mouse=a
" show the command I'm cooking up in the bottom right of the screen
set showcmd
" modeline can be used for file-specific settings declared at the top of the file,
" unfortunately it currently has a vulnerability allowing arbitrary code execution
set nomodeline
" Try these suffixes for things like gf
set suffixesadd+=.yml,.py,.cpp,.h,.md,.sh,.txt
" Use tags relative to current file and current directory
set tags=./tags,tags
" Color column at character 80
set colorcolumn=80
highlight ColorColumn guibg=#305955
" Always open diffs in vertical splits
set diffopt+=vertical
" Use histogram and indent-heuristic for nicer vimdiff
set diffopt+=algorithm:histogram,indent-heuristic
" Preview substitutions. I previously used the traces.vim plugin for this
set inccommand=split

" settings which are different between vim and nvim
if has('nvim')
    let g:terminal_scrollback_buffer_size = 100000 
else
	set t_kB=[Z
    set termwinscroll=100000
endif

" My tabs should default to 4 spaces
set shiftwidth=0 " if 0, use value of tabstop
set softtabstop=-1 " If negative, use value of shiftwidth (which uses tabstop)
set tabstop=4
set expandtab

" Show the number of matches for a search in the bottom right corner
set shortmess-=S

" By default, stop syntax highlighting past 20,000 lines
syntax sync minlines=20000

" Gui options
if has("gui_running")
	" Use non-gui tabline
	set guioptions-=e
	" gvim settings to remove menu bar and toolbar
	set guioptions-=m
	set guioptions-=T
	" gvim remove lefthand scrollbar
	set guioptions-=L
	set guioptions-=r
	" set gvim font
	set guifont=Source\ Code\ Pro\ 13,Consolas:h14:cANSI
	" don't blink cursor
	set guicursor+=a:blinkon0
endif

"******** PATH STUFF ********" " TODO: Make this a plugin
let s:path_map={"default" : ".,,**"}

function s:get_shallowest_directory()
	return strpart(getcwd(), (strridx(getcwd(), '/') + 1))
endfunction

function! SetCDPath()
	let l:shallowest_dir = s:get_shallowest_directory()
	let g:path_key = has_key(s:path_map, l:shallowest_dir) ? l:shallowest_dir : "default"

	execute "set path=".get(s:path_map, g:path_key)
endfunction
" Set path on startup
command! SetCDPath call SetCDPath()
SetCDPath

augroup me
	autocmd!
	" associate .p8 files with the lua filetype
	autocmd BufNewFile,BufRead *.p8 setlocal ft=lua

	" Change path based on current directory
	autocmd DirChanged window SetCDPath
	autocmd DirChanged tabpage SetCDPath
	autocmd DirChanged global SetCDPath
	autocmd WinEnter * SetCDPath
augroup END

" Use ag for :grep and :lgrep
if executable('ag')
	set grepprg=ag\ --vimgrep
endif

" completion options
set completeopt=menu,menuone

" default foldmethod for simplicity
set foldmethod=indent
" Kinda hacky way of defaulting to unfolded
set foldlevel=99

" toggle all folded
nnoremap <expr> z<Space> &foldlevel == 0 ? ":set foldlevel=99<CR>" : ":set foldlevel=0<CR>"

" Highlight tabs - hopefully this isn't too slow
augroup HiglightTabs
	autocmd!
	highlight Tabs guibg=#353535
	autocmd BufWinEnter,VimEnter * :silent! call matchadd("Tabs", "\t", -1)
augroup END

" Define tags only by line number, reduces filesize and help with some other things at the cost of
" potentially getting out of sync. Fortunately, we regen tags file all the time.
let g:gutentags_ctags_extra_args = ["-n"]

function! GetPathKey()
	return g:path_key
endfunction

function! SetStatusLine()
	set statusline=
	set statusline+=%1*%{getcwd()}\/
	set statusline+=%0*%f
	set statusline+=%0*\ %m

	set statusline+=%=

	set statusline+=%{gutentags#statusline()}
	set statusline+=[%{GetPathKey()}]
	set statusline+=%{FugitiveStatusline()}
	set statusline+=\ %y
	set statusline+=\ %l:%c
	set statusline+=\ %P
endfunction
command! SetStatusLine call SetStatusLine()
SetStatusLine

"" KEYS
" ===== LEADER MAPPINGS ===== "
nnoremap <Space> <Nop>
let mapleader=" "
let maplocalleader="\\"

" Find files, buffers and symbols
nnoremap <leader>e :find *
nnoremap <leader>b :b <C-z>
nnoremap <leader>] :tag 

" Select whole buffer
nnoremap <leader>a ggVG

" grep
nnoremap <leader>/ :silent grep! "" \| redraw!<C-Left><C-Left><Left><Left>
nnoremap <leader>8/ :silent grep! "<C-r><C-w>" \| redraw!<C-Left><C-Left><Left>

" Open a new tab
nnoremap <leader>gt :tab split<CR>
nnoremap <leader>gT :-tab split<CR>
" Close the current tab
nnoremap <leader>gk :tabc<CR>
" Go to tab by number
let s:number = 0
while s:number < 10
	execute 'nnoremap g' . s:number . ' ' . s:number . 'gt'
	let s:number += 1
endwhile

" Open a terminal in the current split
nnoremap <leader><CR> :terminal<CR>
" Split controls
nnoremap <leader>h :vsp<CR>
nnoremap <leader>j :sp<CR><C-w><C-j>
nnoremap <leader>k :sp<CR>
nnoremap <leader>l :vsp<CR><C-w><C-l>

" Search for the current visual selection
xnoremap * y/\V<C-r>0<CR>

" ===== RE-MAPPINGS ===== "
" swap gj j, gk k
" if prepended with a count, j and k work as normal
nnoremap <expr> j (v:count ? 'j' : 'gj')
nnoremap <expr> k (v:count ? 'k' : 'gk')
nnoremap gj j
nnoremap gk k
" Swap gF and gf
nnoremap gf gF
nnoremap gF gf
vnoremap gf gF
vnoremap gF gf
" Swap ' and `
for first in ['', 'g', '[', ']']
	for mode in ['n', 'x', 'o']
		execute mode . 'noremap ' . first . "' " . first . "`"
		execute mode . 'noremap ' . first . "` " . first . "'"
	endfor
endfor

" Bring Y in line with D and C
nnoremap Y y$

" Make q; do the same thing as q: so I don't have to press shift between the q
" and the ;
nnoremap q; q:

" map ., and ,. (and shift+those) to .* in insert and commnad line modes for easier globbing in regex patterns
noremap! ., .*
noremap! ,. .*
noremap! <> .*
noremap! >< .*

" Add - to iskeyword, making those characters part of 'words' as far as completion, w, etc...
" is concerned
set iskeyword+=-

" Open the vimrc, this mapping shadows some select mode thing, but I've never intentionally used
" select mode anyway
nnoremap gh :tabe $MYVIMRC<CR>

" ===== WINDOW MAPPINGS ===== "
" Terminal mappings
" Start in insert mode
autocmd TermOpen * startinsert
" paste
tnoremap <C-v> <C-\><C-n>pA
" go to normal mode 
tnoremap <C-w><C-n> <C-\><C-n>
" go back to terminal mode
nnoremap <C-w><C-n> A
inoremap <C-w><C-n> <Esc>
" <C-6>
tnoremap  <C-\><C-n>:b #<CR>
" Refresh terminal
tnoremap <C-l> <C-\><C-n><C-l>
" change windows
tnoremap <C-w><C-h> <C-\><C-n><C-w>h
tnoremap <C-w><C-j> <C-\><C-n><C-w>j
tnoremap <C-w><C-k> <C-\><C-n><C-w>k
tnoremap <C-w><C-l> <C-\><C-n><C-w>l

" omni complete with <C-L> in insert mode
inoremap <C-l> <C-x><C-o>

" Toggle the quickfix window
nnoremap <silent> <F2> :call QuickFix_Toggle()<CR>

" For conceal markers.
if has('conceal')
	set conceallevel=2 concealcursor=
endif

" Leaps!
nnoremap <silent> <leader>o :call Leap(0)<CR>
nnoremap <silent> <leader>i :call Leap(1)<CR>

" I never want to accidentally do this
nnoremap <C-w>o :echo "Use :on[ly]"<CR>
nnoremap <C-w><C-o> :echo "Use :on[ly]"<CR>

"############### NVIM STUFF ####################"
lua << EOF
-- Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"bash",
                      "c",
                      "cmake",
                      "cpp",
                      "dart",
                      "dockerfile",
                      "go",
                      "html",
                      "javascript",
                      "json",
                      "latex",
                      "lua",
                      "make",
                      "perl",
                      "python",
                      "query",
                      "racket",
                      "regex",
                      "rust",
                      "scheme",
                      "toml",
                      "tsx",
                      "typescript",
                      "vim",
                      "yaml",
                      "zig"}, -- either "all" or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
  indent = {
    enable = true,              -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,              -- false will disable the whole extension
    keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
    },
  },
}

-- Treesitter playground
require "nvim-treesitter.configs".setup {
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>e', builtin.find_files, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
EOF
