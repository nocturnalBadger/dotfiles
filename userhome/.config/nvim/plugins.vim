call plug#begin('~/.local/share/nvim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'scrooloose/nerdtree'
Plug 'neomake/neomake'
Plug 'Shougo/deoplete.nvim'
Plug 'davidhalter/jedi'
Plug 'deoplete-plugins/deoplete-jedi'
Plug 'ervandew/supertab'
Plug 'google/vim-maktaba'
Plug 'google/vim-coverage'
Plug 'ludovicchabant/vim-gutentags'
Plug 'lervag/vimtex'


call plug#end()

" deocomplete
let g:deoplete#enable_at_startup = 1
" Vimtex hook
call deoplete#custom#var('omni', 'input_patterns', {
      \ 'tex': g:vimtex#re#deoplete
      \})

" Supertab
let g:SuperTabDefaultCompletionType = "<c-n>"

" NeoMake
call neomake#configure#automake('nwr', 750)
let g:neomake_tex_enabled_makers = ['pdflatex']


