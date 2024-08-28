"------------------------------------------------------
" Initialize
"------------------------------------------------------
autocmd!

set encoding=utf-8         " vimエンコーディング設定
scriptencoding utf-8       " vimスクリプトエンコーディング設定
set fenc=utf-8             " デフォルトファイルエンコーディング設定
set nocompatible           " vi互換モードで動作させない

"------------------------------------------------------
" Basics
" ----------------------------------------------------
" ディスプレイ設定:
set notitle                  " タイトルを表示する
set number                 " 行番号を表示する
"set cursorline             " 現在の行を強調表示
"set cursorcolumn           " 現在の行を強調表示（縦）
set ruler                  " ステータスラインに現在の選択行について表示する
set laststatus=2           " 0=ステータスライン非表示 2=ステータスラインを常に表示
"set visualbell             " ビープ音有効化
set nobomb                 " デフォルトファイルをBOMなしにする
set lazyredraw             " コマンド実行中には再描画を行わない
set autoread               " ファイル改変されたら自動で読み直す
set mouse=a                " マウスクリックによるカーソル移動やウインドウ移動を有効化

" 検索設定:
set hlsearch               " 検索した言葉をハイライトで表示する
set incsearch              " 検索時はインクリメントサーチを有効にする
set ignorecase             " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set wrapscan               " 文末まで検索ワード部分が行ったら次は文頭に戻る
set wildmenu               " コマンドモードでのTabによるファイル名補完機能を有効化
set history=5000           " コマンドラインモードで保存する履歴件数
"set showmatch             " カッコ入力時で対応するカッコに0.5秒だけジャンプする
set hidden                 " バッファを開く前に保存警告を出さいない
" }}}

" バックアップ設定:
set nobackup               " バックアップファイルを作成しない
set noswapfile             " swapfileを作成しない
set nowritebackup

" 対応する括弧にカーソルを置かないようにする
let loaded_matchparen = 1

" [nvim] %sした際に変換シミュレートの画面を出しての置換を可能にする
if has('nvim')
    set inccommand=split
endif

" クリップボード設定 (ヤンクおよびペースト機能のクリップボードとの共有化)
if has('unix')
    set clipboard=unnamedplus " linuxのみ有効
elseif has('mac')
    set clipboard+=unnamed
else
    set clipboard=unnamed
endif

" mapleaderはSpace
let mapleader = "\<Space>"

" 前回開いたカーソル位置を保持する
augroup KeepLastCursorPos
autocmd!
 autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
augroup END

" :grep でripgrepを使う
if executable('rg')
    let &grepprg = 'rg --vimgrep --hidden'
    set grepformat=%f:%l:%c:%m
endif

" :grep したら Quick Fix ウインドウをそのまま開く
augroup GrepCmd
    autocmd!
    autocmd QuickFixCmdPost vim,grep,make if len(getqflist()) != 0 | cwindow | endif
augroup END

"------------------------------------------------------
" Vim-Plug
"------------------------------------------------------
if filereadable(expand('~/.vim/plugins/_load.vim'))
source ~/.vim/plugins/_load.vim
endif

"------------------------------------------------------
" UI
"------------------------------------------------------
" [NOTICE] User Color Scheme Path:
"   以下の場所に配置. なければ作成
"   $HOME/.vim/colors or  $HOME/.config/nvim/colors

" シンタックスハイライト有効化
syntax enable

colorscheme elflord
" set background=dark

" [NOTICE] 半透明モードを利用したい場合は以下を使用
" highlight Normal ctermbg=NONE guibg=NONE
" highlight NonText ctermbg=NONE guibg=NONE
" highlight LineNr ctermfg=darkcyan guibg=darkcyan ctermbg=NONE guibg=NONE
" highlight SignColumn ctermbg=NONE guibg=NONE
" highlight EndOfBuffer ctermbg=NONE guibg=NONE

"------------------------------------------------------
" Commands
"------------------------------------------------------
" [:Format] Vim組込のファイル全体のインデントフォーマット機能を実行する
" :command! -nargs=0 Format :normal gg=G

" [:GetPath] 開いているファイルのフルパスを表示
:command! -nargs=0 GetPath :echo expand("%:p")

" [:GetPath] 開いているファイルのフルパスをクリップボードコピー
:command! -nargs=0 CopyPath :let @+ = expand('%:p')

"------------------------------------------------------
" Key Maps
"------------------------------------------------------
" Esc2回でハイライトを解除する
nnoremap <silent><Esc><Esc> :<C-u>noh<CR><Esc>

" マクロ機能を無効化
nmap q <Nop>

" :grep の指定範囲エイリアス
cnoreabbrev gr grep
cnoreabbrev gall **/*
cnoreabbrev gfile %
cnoreabbrev ggit `git ls-files`

" leader + e で QuickFixWindowをトグル開閉
if exists('g:__QUICKFIX_TOGGLE__')
    finish
endif
let g:__QUICKFIX_TOGGLE__ = 1

function! ToggleQuickfix()
    let s:nr1 = winnr('$')
    cwindow

    let s:nr2 = winnr('$')
    if s:nr1 == s:nr2
        cclose
    endif
endfunction
nnoremap <script> <silent><Leader>e :call ToggleQuickfix()<CR>

"------------------------------------------------------
" Indent And Comment
"------------------------------------------------------
" NOTICE:
"    formatoptions+=r: C言語式複数行 /** */コメントで、開業時に * を自動挿入
"

" トグルセット:
filetype plugin on "ファイルタイプの検索を有効にする
filetype indent on "ファイルタイプに合わせたインデントを利用

" デフォルト設定:
set tabstop=2              " 何個分のスペースで1つのタブとして扱うか
set shiftwidth=2           " >> などのインデントでどれだけのスペース数移動を使うか
set expandtab              " tab文字は半角スペースに変換(空白は常にスペースを利用する)
set autoindent             " オートインデント有効化. 改行時にはデフォルトで同じインデント幅を確保
set smartindent            " set autoindent必須. {} ブロック検知でのCライク自動インデント有効化

" ファイルタイプ毎設定:
augroup fTypes
    autocmd!
    autocmd FileType javascript       setlocal shiftwidth=2 tabstop=2 expandtab formatoptions+=r
    autocmd FileType typescript       setlocal shiftwidth=2 tabstop=2 expandtab formatoptions+=r
    autocmd FileType javascriptreact  setlocal shiftwidth=2 tabstop=2 expandtab formatoptions+=r
    autocmd FileType typescriptreact  setlocal shiftwidth=2 tabstop=2 expandtab formatoptions+=r
    autocmd FileType html             setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType css              setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType scss             setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType sass             setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType json             setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType yml              setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType c                setlocal shiftwidth=4 tabstop=4 expandtab formatoptions+=r
    autocmd FileType cpp              setlocal shiftwidth=4 tabstop=4 expandtab formatoptions+=r
    autocmd FileType cs               setlocal shiftwidth=4 tabstop=4 expandtab formatoptions+=r
    autocmd FileType php              setlocal shiftwidth=4 tabstop=4 expandtab formatoptions+=r
    autocmd FileType go               setlocal shiftwidth=4 tabstop=4 noexpandtab
    autocmd FileType bash             setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType zsh              setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType powershell       setlocal shiftwidth=4 tabstop=4 expandtab
    autocmd FileType vim              setlocal shiftwidth=4 tabstop=4 expandtab
    autocmd FileType snippets         setlocal shiftwidth=2 tabstop=2 expandtab
augroup END
