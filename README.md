VIM-CMake-Project v2.0.1
===============

About
=====
This is a fork of https://github.com/Ignotus/vim-cmake-project 

CMake-Project is a plugin for cmake projects effective management. It provides
a sidebar that displays project files in the tree view.

[![VCP](http://i.imgur.com/wGeVbl.png)](http://i.imgur.com/wGeVbl.png)

Installing
==========

Before installation, please check your Vim supports python by running :echo has('python'). 1 means you're all set; 0 means you need to install a Vim with python support. If you're compiling Vim yourself you need the 'big' or 'huge' feature set.

If you don't have a preferred installation method, I recommend installing pathogen.vim, and then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/sigidagi/vim-cmake-project.git

Or for Vundle users:

Add Plugin 'sigidagi/vim-cmake-project' to your ~/.vimrc and then:

    either within Vim: :PluginInstall
    or in your shell: vim +PluginInstall +qall

Usage
=====

Open cmake project file "CMakeLists.txt" with vim. File not necessary has to be in current working directory.
Call cammand to build project

    :CMake 
It will create build directory (if it do not exist), build the project and save all binaries into that directory. 

    :CMakeBar 
will open sidebar with project files. Command utilizes NERDTree functionality. For navigation and viewing see NERDTree documantation. Sidebar view will only schow C/C++ related files and TXT files. 

License
=======
This product is released under the [BSD License](http://opensource.org/licenses/bsd-3-clause).
