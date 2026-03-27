
" .vimrc.old
" Changelog:
" 2019-11-19: Init 'fully working' 'standard' .vimrc
" 2026-03-27: Most of this was already in min.vimrc ; what's left here is long-lingering
"   tbd and 'used to be useful' stuff. Left more for reference... removed already integrated stuff


"" Plugins, cont
call plug#begin('~/.vim/plugged')

" Documentation
Plug 'kkoomen/vim-doge'
" Requires pip3 install clang, and libclang.so
" May need (in /usr/lib/x86_64-linux-gnu) ln -s libclang-X.0.so.1 libclang.so
let g:doge_doc_standard_cpp = 'doxygen_qt'
let g:doge_doc_standard_c   = 'doxygen_qt'
let g:doge_mapping_comment_jump_forward = '<Leader><Tab>'
let g:doge_mapping_comment_jump_backward = '<Leader><S-Tab>'
let g:doge_mapping = '<Leader>doc' " L-d (default) is expanded diagnostic in ycm
" let g:doge_comment_jump_modes = ['n', 's'] " Removed 'i', so in 'i' mode, use YCM
" To include custom args to clang, in buffer
" let b:doge_clang_args = ['-I', '/my/include/path']

" Auto-complete
Plug 'ycm-core/YouCompleteMe', { 'do': 'python3 ./install.py --clang-completer --clangd-completer' }
" Requires clang-X and libclangY-X for clang, and clang-tools-X for clangd (apt)
" ubuntu16: sudo apt-get install clang-6.0 clang-tools-6.0 libclang1-6.0
let g:ycm_use_clangd = 1 " Want to use clangd unless broken
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
" Todo: https://stackoverflow.com/questions/24500281/youcompleteme-and-syntastic-compatibility

" Under consideration
" tagbar, delimitMate " https://www.howtoforge.com/tutorial/vim-editor-plugins-for-software-developers/

" From him:
"Plug 'crtlpvim/ctrlp.vim'
call plug#end() " Plugins visible after this, and colorschemes

"" Old-Old stuff, not yet processed
" Filetype detection of C
augroup project
	autocmd!
	autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup end


"" Useful stuff, from Paul, idk if want to use/how yet

"" Visual mode pressing * or # searches for the current selection
"" Super useful! From an idea by Michael Naumann
"vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
"vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
"
"function! CmdLine(str)
"    call feedkeys(":" . a:str)
"endfunction
"
"function! VisualSelection(direction, extra_filter) range
"    let l:saved_reg = @"
"    execute "normal! vgvy"
"
"    let l:pattern = escape(@", "\\/.*'$^~[]")
"    let l:pattern = substitute(l:pattern, "\n$", "", "")
"
"    if a:direction == 'gv'
"        call CmdLine("Ack '" . l:pattern . "' " )
"    elseif a:direction == 'replace'
"        call CmdLine("%s" . '/'. l:pattern . '/')
"    endif
"
"    let @/ = l:pattern
"    let @" = l:saved_reg
"endfunction
"
"

"" Close the current buffer
"map <leader>bd :Bclose<cr>:tabclose<cr>gT
"
"" Close all the buffers
"map <leader>ba :bufdo bd<cr>
"
"" move between buffers
"map <leader>l :bnext<cr>
"map <leader>h :bprevious<cr>
"
"" Useful mappings for managing tabs
"map <leader>tn :tabnew<cr>
"map <leader>to :tabonly<cr>
"map <leader>tc :tabclose<cr>
"map <leader>tm :tabmove
"map <leader>t<leader> :tabnext<cr>
"
"" Let 'tl' toggle between this and the last accessed tab
"let g:lasttab = 1
"nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
"au TabLeave * let g:lasttab = tabpagenr()
"
"
"" Opens a new tab with the current buffer's path
"" Super useful when editing files in the same directory
"map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
"
"
"" Specify the behavior when switching between buffers
"try
"  set switchbuf=useopen,usetab,newtab
"  set stal=2
"catch
"endtry

"" persistant undo
"try
"    set undodir=/tmp/
"    set undofile
"catch
"endtry

" This converts all snake case to camelCase, keeping leading underscore, not touching words that start with a Cap
function! ReCap()
  silent! %s/\<\(_\+\)\(\w\+\)/\1$ \2/g " Split leading _, for clarity
  let @/ = '\<\l\a\w*_\w*' " the search for valid words (new word, lowercase, 2nd char isn't _, and at least 1 under
  let @q = 'ncrcN@q' " the crc is from tpope; n to next, run the converter, then recurse
  normal! gg
  normal! @q
  silent! %s/_$ \(\w\+\)/_\1/g " Undo the sep leading under
endfunction

" References still using
" http://stevelosh.com/blog/2010/09/coming-home-to-vim/using-the-leader
" https://stackoverflow.com/questions/1764263/what-is-the-leader-in-a-vimrc-file#1764336
