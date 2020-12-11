"     ^
"     h
" < j   l >
"     k
"     v
"UP
noremap h k
"Down
noremap k j
"Left
noremap j h
"Right
noremap l l
noremap H 5k
noremap K 5j
noremap J 5h
noremap L 5l

noremap a i
noremap i a
noremap A I
noremap I A
noremap ; :
inoremap jk <esc>

noremap ;d :Dashboard<CR>

noremap = nzz
noremap - Nzz
noremap <LEADER><CR> :nohlsearch<CR>

noremap <LEADER>r :e ~/.config/nvim/init.vim<CR>
"noremap R :source ~/.config/nvim/init.vim<CR>

noremap <c-s> :w<CR>

noremap <c-x> :bd<CR>
nmap <tab> :bn<CR>

nmap <LEADER>[ :bp<CR>
nmap <LEADER>] :bn<CR>

nmap <space>i <c-w>k
nmap <space>j <c-w>h
nmap <space>l <c-w>l
nmap <space>k <c-w>j

noremap <space>r :Qrun<CR>
noremap <space>c :call CommonRun()<CR>

map <LEADER><LEADER> <Esc>/<[]><CR>:nohlsearch<CR>c4k
