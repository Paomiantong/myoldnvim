func! CommonRun()
  exec "w"
  if &filetype == 'c'
    set splitright
    exec "!clang % -Wall -o %<"
    :vsp
    :res -10
    :term ./%<
    exec "!rm -rf ./%<"
  elseif &filetype == 'cpp'
    set splitright
    exec "!clang++ -std=c++11 % -Wall -o %<"
    :vsp
    :res -10
    :term ./%<
    exec "!rm -rf ./%<"
  elseif &filetype == 'java'
    exec "!javac %"
    exec "!time java %<"
  elseif &filetype == 'sh'
    :!time bash %
  elseif &filetype == 'python'
    set splitright
    :vsp
    :term python3 %
  endif
endfunc

if !has('python3')
	echomsg "[Qrun]Python3[x]"
	finish
endif
function! Qrun() abort
	if findfile("qr.json")==""
		echomsg "Can`t find qr.json"
		return
	endif
	let l:qrf = fnamemodify("qr.json",":p")
	let l:data = {}
python3 <<EOM
import vim
import json
path = vim.eval("qrf")
data = vim.eval("data")
with open(path) as file:
	data=json.loads(file.read())
	vim.command("let l:data=%s"%data)
EOM
	try
		exe l:data[bufname("%")]
	catch /.*/
		echomsg "[Qrun]Error"
	endtry
		
endfunction

command! Qrun call Qrun()
