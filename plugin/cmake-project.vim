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
    \  'g:cmake_project_show_bar':                0,
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
    "au! BufRead,BufNewFile *.cmake,*.cmake.in   setfiletype cmake
    au BufRead,BufNewFile,BufEnter CMakeLists.txt       setfiletype cmake
    au FileType cmake :call s:cmake_project_activate()
    au BufDelete CMakeLists.txt :call s:cmake_project_deactivate()
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
    
    let s:cmake_project_source_directory = expand("<afile>:p:h")
endfunction

" Remove cmake commands and filter from NERDTree
function! s:cmake_project_deactivate() abort
    delcommand CMake
    delcommand CMakeBar
    let g:NERDTreeIgnore = []
   
    " 
    let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != bufnr(expand("<afile>"))')
    let bjump = (blisted + [-1])[0]
    if bjump > 0
        execute 'buffer ' . bjump
    endif

    "if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary")  
        "quit 
    "endif
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
function! s:cmake_project_toggle_barwindow() abort
    if (!exists("b:NERDTreeType"))
        let g:NERDTreeIgnore = ['\(\.txt\|\.cpp\|\.hpp\|\.c\|\.h\)\@<!$[[file]]']
        call g:NERDTreeCreator.CreatePrimary(s:cmake_project_source_directory)
    else
        call g:NERDTreeCreator.TogglePrimary(s:cmake_project_source_directory)
    endif
endfunction

