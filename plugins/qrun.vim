function SelectLanguage() abort
    let filename = expand("%:p")
    let target = expand("%:p:r")
    let suffix = &filetype
    let language = {
        \ 'c' : {'cmd': [target], 'cmplCmd': ['clang', filename, '-Wall', '-o', target], 'clean': ['rm', '-rf', target]},
        \ 'cpp' : {'cmd': [target], 'cmplCmd': ['clang++','-std=c++11', filename, '-Wall', '-o', target], 'clean': ['rm', '-rf', target]},
        \ 'sh' : {'cmd': ['bash', filename]},
        \ 'python': {'cmd': ['python3', filename]},
        \ 'rust': {'cmd': ['cargo', 'run'], 'env': {'RUST_BACKTRACE': 1}},
        \ }
    if(has_key(language, suffix))
        return language[suffix]
    else
        return {'NOTFOUND': 1}
    endif
endfunction


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

" the buffer number of code runner
let s:code_runner_bufnr = 0
let g:code_runner_focus = 1

let s:winid = -1
let s:target = ''
let s:cleanTarget = []
let s:runner_lines = 0
let s:runner_jobid = 0
let s:compile_jobid = 0
let s:runner_status = {
      \ 'is_running' : 0,
      \ 'has_errors' : 0,
      \ 'exit_code' : 0
      \ }

function! s:start(task) abort
    let s:start_time = reltime()
    let opts = {
            \ 'on_stdout': 'On_stdout', 
            \ 'on_stderr' : 'On_stdout', 
            \ }

    if has_key(a:task, 'env')
        let opts = extend(opts, {'env': a:task.env})
    endif

    if has_key(a:task, 'cmplCmd')
        call Setlines(s:code_runner_bufnr, s:runner_lines, s:runner_lines+1, 0, ["[Compiling] " . join(a:task.cmplCmd, ' ')])
        let s:runner_lines += 1
        let s:runner_jobid = jobstart(a:task.cmplCmd, extend(opts, {'on_exit': 'On_compile_exit'}))
        let s:target = a:task.cmd
    else
        call Setlines(s:code_runner_bufnr, s:runner_lines, s:runner_lines+1, 0, ["[Running] " . join(a:task.cmd, ' ')])
        let s:runner_lines += 1
        let s:runner_jobid = jobstart(a:task.cmd, extend(opts, {'on_exit': 'On_exit'}))
    endif

    if has_key(a:task, 'clean')
        let s:cleanTarget = a:task.clean
    endif

    if s:runner_jobid > 0
        let s:runner_status = {
        \ 'is_running' : 1,
        \ 'has_errors' : 0,
        \ 'exit_code' : 0
        \ }
    endif
endfunction

function! s:open_win() abort
  if s:code_runner_bufnr !=# 0 && bufexists(s:code_runner_bufnr) && index(tabpagebuflist(), s:code_runner_bufnr) !=# -1
    return
  endif
  botright split Runner
  let lines = &lines * 30 / 100
  exe 'resize ' . lines
  setlocal buftype=nofile bufhidden=wipe nobuflisted nolist noswapfile nowrap cursorline nospell nonu norelativenumber winfixheight nomodifiable
  set filetype=runner
  nnoremap <silent><buffer> q :call <SID>close()<cr>
  nnoremap <silent><buffer> i :call <SID>insert()<cr>
  nnoremap <silent><buffer> <C-c> :call <SID>stop_runner()<cr>
  nnoremap <silent><buffer> <tab> <c-w>k <CR>
  augroup runner
    autocmd!
    autocmd BufWipeout <buffer> call <SID>stop_runner()
  augroup END
  let s:code_runner_bufnr = bufnr('%')
  ":term 'echo hello'
  if exists('*win_getid')
    let s:winid = win_getid(winnr())
  endif
  if !g:code_runner_focus
    wincmd p
  endif
endfunction

function! s:insert() abort
  call inputsave()
  let input = input('input >')
  if !empty(input) && s:runner_status.is_running == 1
    call Setlines(s:code_runner_bufnr, s:runner_lines , s:runner_lines + 1, 0, [input])
    let s:runner_lines+=1
    call s:send(s:runner_jobid, input)
  endif
  normal! :
  call inputrestore()
endfunction

function! s:close() abort
  call s:stop_runner()
  if s:code_runner_bufnr != 0 && bufexists(s:code_runner_bufnr)
    exe 'bd ' s:code_runner_bufnr
  endif
endfunction

function! s:send(id, data) abort
    if type(a:data) == type('')
        call jobsend(a:id, a:data . "\n")
    else
        call jobsend(a:id, a:data)
    endif
endfunction

function! On_stdout(job_id, data, event) abort
  if a:job_id !=# s:runner_jobid
    " that means, a new runner has been opennd
    " this is previous runner exit_callback
    return
  endif
  if bufexists(s:code_runner_bufnr)
    call Setlines(s:code_runner_bufnr, s:runner_lines , s:runner_lines + 1, 0, a:data)
  endif
  let s:runner_lines += len(a:data)-1
endfunction


function! On_exit(job_id, data, event) abort
  if a:job_id !=# s:runner_jobid
    " that means, a new runner has been opennd
    " this is previous runner exit_callback
    return
  endif
  let s:end_time = reltime(s:start_time)
  let s:runner_status.is_running = 0
  let s:runner_status.exit_code = a:data
  let done = ['', '[Done] exited with code=' . a:data . ' in' . reltimestr(s:end_time) . ' seconds']
  if bufexists(s:code_runner_bufnr)
    call Setlines(s:code_runner_bufnr, s:runner_lines , s:runner_lines + 1, 0, done)
  endif
  if len(s:cleanTarget) != 0
    call jobstart(s:cleanTarget)
  endif
endfunction

function! On_compile_exit(id, data, event) abort
  if a:id !=# s:runner_jobid
    " make sure the compile exit callback is for current compile command.
    return
  endif
  if a:data == 0
        call s:start({'cmd': s:target, 'needCmpl': 0})
  else
    let s:end_time = reltime(s:start_time)
    let s:runner_status.is_running = 0
    let s:runner_status.exit_code = a:data
    let done = ['', '[Done] exited with code=' . a:data . ' in' . reltimestr(s:end_time) . ' seconds']
    call Setlines(s:code_runner_bufnr, s:runner_lines , s:runner_lines + 1, 0, done)
  endif
endfunction

function! s:stop_runner() abort
  if s:runner_status.is_running == 1
    call jobstop(s:runner_jobid)
  endif
endfunction

function! Setlines(buffer, start, end, strict_indexing, replacement) abort
  if bufexists(a:buffer)
    let ma=getbufvar(a:buffer, '&ma')
    call setbufvar(a:buffer, '&ma', 1)
    call nvim_buf_set_lines(a:buffer, a:start , a:end, a:strict_indexing, a:replacement)
    call nvim_win_set_cursor(s:winid, [nvim_buf_line_count(s:code_runner_bufnr), 1])
    call setbufvar(a:buffer, '&ma', ma)
  endif
endfunction

" 获取job名称
function qrun#GetJobStatus() abort
    return s:runner_status.is_running ? "Running" : "Done"
endfunction

" 获取jobID
function qrun#GetJobId() abort
    return s:runner_jobid == 0 ? s:compile_jobid : s:runner_jobid
endfunction
" 执行job
func! qrun#Run()
    let task = SelectLanguage()
    if has_key(task, 'NOTFOUND')
        echomsg "[Runner]: This filetype is not supported"
        return
    endif
    let s:target = ''
    let s:cleanTarget = ''
    let s:runner_jobid = 0
    let s:runner_lines = 0
    let s:runner_status = {
        \ 'is_running' : 0,
        \ 'has_errors' : 0,
        \ 'exit_code' : 0
        \ }
    call s:open_win()
    call s:start(task)
endfunc

command! Qrun call Qrun()

