call plug#begin('~/.vim/plugged')
" Файловый менеджер
Plug 'preservim/nerdtree'

" Автодополнение
Plug 'ycm-core/YouCompleteMe'

" Подсветка синтаксиса
Plug 'sheerun/vim-polyglot'

" Комментирование кода
Plug 'tpope/vim-commentary'

" Статусная строка
Plug 'vim-airline/vim-airline'

call plug#end()

" Копирование в буфер обмена Termux
vnoremap <C-c> y:call system("termux-clipboard-set", @")<CR>
" Вставка из буфера обмена Termux
nnoremap <C-v> :let @"=system("termux-clipboard-get")<CR>p
