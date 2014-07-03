" vim-cmake-project
" Plugin provides list and navigation of project files on side bar with a help of NERDTree plugin 
" and command(s) for building cmake projects.
" Side bar shows only project related files: C/C++. ( NERDTree is filtered out )
" CMake command is deactivated and NERDTree structure is restored when CMakeLists.txt is removed from buffer.
"
" Last change: 2014 Juni 29
" Maintainer: Sigitas Dagilis sigidagi@gmail.com
" License: BSD
"
" allow users to disable loading plugin by providing global variable.
" another reason - to avoid loading plugin twice.
if exists("g:loaded_cmake_project")
    finish
endif

" First should be loaded nerd-tree plugin. 
if !exists('g:loaded_nerd_tree')
    echohl WarningMsg   
    echo '[cmake-project] Warning: "NERD-Tree" plugin is needed for complete functionality'
    echohl NONE
endif

" function first check for existence of specified option in .vimrc 
" keeping global option in dictionary for compactness, i.e later if options will grow
" it will be more convinient to keep in one place.
function! s:set_options()
    let s:options = {
    \  'g:cmake_project_show_bar':                1,
    \  'g:loaded_cmake_project':                  1,
    \  'g:cmake_project_build_directory':        'build'
    \ }

    for aOption in keys(s:options)
        if !exists(aOption)
            let {aOption} = s:options[aOption]
        endif
    endfor
endfunction

function! s:init()
  augroup vim-cmake-project.vim
    au!
    au BufNewFile,BufRead,BufEnter CMakeLists.txt :call s:cmake_project_activate() 
    au BufDelete CMakeLists.txt :call s:cmake_project_deactivate()
    au BufDelete *.cpp :call s:cmake_project_opennext()
  augroup END
endfunction

" Start ---------------------
call s:set_options()
call s:init()

" Commands -------------------
" Check if buffers contains project file CMakeLists.txt. Deactivate commands if such
" file do not exist and vice versa. 
function! s:cmake_project_activate()
    command! -nargs=0 -complete=file CMake call s:cmake_project_build()
    command! -nargs=0 -bar CMakeBar call s:cmake_project_toggle_barwindow()
    
    let g:NERDTreeIgnore = ['\(\.txt\|\.cpp\|\.hpp\|\.c\|\.h\)\@<!$[[file]]']
    let s:cmake_project_source_directory = expand("<afile>:p:h")
    
    if !exists("t:NERDTreeBufName") && g:cmake_project_show_bar == 1
        call g:NERDTreeCreator.CreatePrimary(s:cmake_project_source_directory)
    endif
endfunction

function! s:cmake_project_jumptofile(path)
        let p = g:NERDTreePath.New(a:path)  "get the path to a file

        call g:NERDTreeFocus()              " change focus to nerd tree view
        call b:NERDTreeRoot.reveal(p)       " find that file on the tree 
        call g:nerdtree#invokeKeyMap("o")   " invoke open action
endfunction

function! s:cmake_project_opennext()
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1 && winnr("$") == 1
        let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != bufnr(expand("<afile>"))')
        let bjump = (blisted + [-1])[0]
        if bjump > 0
            call s:cmake_project_jumptofile(fnamemodify(bufname(bjump), ":p"))
        endif
    endif
endfunction

" Remove cmake commands and filter from NERDTree
function! s:cmake_project_deactivate() abort
    
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1 && winnr("$") == 1
        let choice = confirm(  
            \ "Closing CMakeLists.txt will close project. Are you sure?",
            \ "&Yes\n&No, return to project", 1) 
        if choice == 1
            delcommand CMake
            delcommand CMakeBar
            let g:NERDTreeIgnore = []
            quit
        endif 
       
        " Restore CMakeLists.txt by opening it again
        call s:cmake_project_jumptofile(expand("<afile>:p"))
    endif
endfunction

" Build project ---------- 
function! s:cmake_project_build() abort
    let build_directory = s:cmake_project_source_directory . "/" . g:cmake_project_build_directory

    if !isdirectory(build_directory)
        call mkdir(build_directory, "p")
    endif

    exec '!cmake' "-G\"Unix Makefiles\" -B" . build_directory . " -H" . s:cmake_project_source_directory  
endfunction

" Toggle Bar window --------
function! s:cmake_project_toggle_barwindow() 
    if !exists("t:NERDTreeBufName") 
        call g:NERDTreeCreator.CreatePrimary(s:cmake_project_source_directory)
    else
        call g:NERDTreeCreator.TogglePrimary(s:cmake_project_source_directory)
    endif
endfunction
