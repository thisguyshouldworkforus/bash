" VimRC Options

" ~=[ Indentaion Options ]=~
" ======
" Convert tabs to spaces.
set expandtab
" When shifting, indent using four spaces.
set shiftwidth=4
" Indent using four spaces.
set tabstop=4
" Insert “tabstop” number of spaces when the “tab” key is pressed.
set smarttab
" Do not automatically indent lines
set noautoindent
" ======

" ~=[ Search Options ]=~
" ======
" Enable search highlighting.
set hlsearch
" Ignore case when searching.
set ignorecase
" Automatically switch search to case-sensitive when search query contains an uppercase letter.
set smartcase
" ======

" ~=[ Text Rendering Options ]=~
" ======
" Always try to show a paragraph’s last line.
set display+=lastline
" Use an encoding that supports unicode.
set encoding=utf-8
" Avoid wrapping a line in the middle of a word.
set linebreak
" The number of screen lines to keep above and below the cursor.
set scrolloff=1
" The number of screen columns to keep to the left and right of the cursor.
set sidescrolloff=5
" Disable Syntax Highlighting
syntax off
" Wrap lines
set wrap
" Set paste mode
set paste
" ======

" ~=[ User Interface Options ]=~
" ======
" Flash the screen instead of beeping on errors.
set visualbell
" Set the window’s title, reflecting the file currently being edited.
set title
" Use colors that suit a dark background.
set background=dark
" ======