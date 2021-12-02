lua <<EOF
local wk = require("which-key")
-- As an example, we will the create following mappings:
--  * <leader>ff find files
--  * <leader>fr show recent files
--  * <leader>fb Foobar
-- we'll document:
--  * <leader>fn new file
--  * <leader>fe edit file
-- and hide <leader>1

wk.register({
  d = {
    name = "defx", -- optional group name
    c = "Copy",
    m = "Move",
    p = "Paste",
    d = "Open",
    K = "New directory",
    N = "New file",
    M = "New multiple files",
    C = "Toggle columns",
    S = "Toggle sort",
    x = "Remove",
    r = "Rename",
    ["!"] = "Execute command",
    l = "Execute system",
    ["yy"] = "Yank path",
    ["<c-h>"] = "Toggle ignored files",
    [";"] = "Repead",
    a = "Cd ..",
    ["~"] = "Cd ~",
    q = "quit",
    ["<space>"] = "Toggle select",
    ["*"] = "Toggle select all",
    cd = "change_vim_cwd",
    },
}, { prefix = "<leader>" })
EOF

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

noremap <LEADER>q :e ~/.config/nvim/plugins/qrun.vim<CR>
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
noremap <space>c :call qrun#Run()<CR>

map <LEADER><LEADER> <Esc>/<[]><CR>:nohlsearch<CR>c4k
