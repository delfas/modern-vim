" Environment {

    " Identify platform {
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return  (has('win32') || has('win64'))
        endfunction
    " }

    " Basics {
        set nocompatible        " Must be first line
        if !WINDOWS()
            set shell=/bin/bash
        else
          set shell=bash
          set shellslash
          set shellcmdflag=-c
          if has('nvim')
            set shellxquote=
          endif
        endif
        " Unset git's core editor setting for --system, --global, and --local
        " Using the current Neovim instance as preferred text editor
        if has('nvim') && executable('nvr')
          let $VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
        endif
        let g:python3_host_prog="/usr/bin/python3"
        let g:python2_host_prog="/usr/bin/python2"
        "
    " }

    " Windows Compatible {
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if WINDOWS()
          if !has('nvim')
              set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
          endif

          " Be nice and check for multi_byte even if the config requires
          " multi_byte support most of the time
          if has("multi_byte")
            " Windows cmd.exe still uses cp850. If Windows ever moved to
            " Powershell as the primary terminal, this would be utf-8
            set termencoding=cp850
            " Let Vim use utf-8 internally, because many scripts require this
            set encoding=utf-8
            setglobal fileencoding=utf-8
            " Windows has traditionally used cp1252, so it's probably wise to
            " fallback into cp1252 instead of eg. iso-8859-15.
            " Newer Windows files might contain utf-8 or utf-16 LE so we might
            " want to try them first.
            set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
          endif
        endif
    " }
    "
    " Arrow Key Fix {
        if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
            inoremap <silent> <C-[>OC <RIGHT>
        endif
    " }

" }
" General {
    scriptencoding utf-8

    set background=dark         " Assume a dark background

    " Allow to trigger background
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg == "dark"
            set background=light
        else
            set background=dark
        endif
    endfunction
    noremap <leader>bg :call ToggleBG()<CR>

    " if !has('gui')
        "set term=$TERM          " Make arrow and other keys work
    " endif

    filetype on
    filetype plugin on
    filetype indent on           " Automatically detect file types.
    "syntax on                   " Syntax highlighting
    "set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing

    if has('clipboard')
        " Add the unnamed register to the clipboard
        set clipboard+=unnamed
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard+=unnamedplus
        endif
    endif

    " Most prefer to automatically switch to the current file directory when
    " a new buffer is opened; to prevent this behavior, add the following to
    " your .vimrc.before.local file:
    "   let g:spf13_no_autochdir = 1
    if !exists('g:spf13_no_autochdir')
        " Always switch to the current file directory
        autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    set virtualedit=all                 " Allow the cursor to go in to "invalid" places
    "set virtualedit=onemore             " Allow for cursor beyond last character
    set history=5000                    " Store a ton of history (default is 20)
    "set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator

    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
    " Restore cursor to file position in previous editing session
    " To disable this, add the following to your .vimrc.before.local file:
    "   let g:spf13_no_restore_cursor = 1
    if !exists('g:spf13_no_restore_cursor')
        function! ResCur()
            if line("'\"") <= line("$")
                silent! normal! g`"
                return 1
            endif
        endfunction

        augroup resCur
            autocmd!
            autocmd BufWinEnter * call ResCur()
        augroup END
    endif

    " Setting up the directories {
        set backup                  " Backups are nice ...
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif

        " To disable views add the following to your .vimrc.before.local file:
        "   let g:spf13_no_views = 1
        if !exists('g:spf13_no_views')
            " Add exclusions to mkview and loadview
            " eg: *.*, svn-commit.tmp
            let g:skipview_files = [
                \ '\[example pattern\]'
                \ ]
        endif
    " }

    if has('nvim')
      tnoremap <Esc> <C-\><C-n>
      tnoremap <C-v><Esc> <Esc>
    endif

    if has('nvim')
      highlight! link TermCursor Cursor
      highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
    endif

    " window switching normal mode
    nnoremap <M-h> <c-w>h
    nnoremap <M-j> <c-w>j
    nnoremap <M-k> <c-w>k
    nnoremap <M-l> <c-w>l

    if has('nvim') "window switching in terminal mode
      tnoremap <M-h> <c-\><c-n><c-w>h
      tnoremap <M-j> <c-\><c-n><c-w>j
      tnoremap <M-k> <c-\><c-n><c-w>k
      tnoremap <M-l> <c-\><c-n><c-w>l
    endif

    " window switching in insert mode
    inoremap <M-h> <esc><c-w>h
    inoremap <M-j> <esc><c-w>j
    inoremap <M-k> <esc><c-w>k
    inoremap <M-l> <esc><c-w>l
    "
    "
    " window switching in visual mode
    vnoremap <M-h> <c-w>h
    vnoremap <M-j> <c-w>j
    vnoremap <M-k> <c-w>k
    vnoremap <M-l> <c-w>l
" }
"
" minpac {
    let g:spf13_bundle_groups=['general', 'programming', 'ruby', 'javascript', 'typescript', 'html', 'misc', 'writing', 'youcompleteme', 'deoplete',]
"
    packadd minpac
    call minpac#init()
    call minpac#add('tpope/vim-scriptease', { 'type':'opt' })
    call minpac#add('k-takata/minpac', { 'type':'opt' })

    command! PackUpdate call minpac#update()
    command! PackClean call minpac#clean()

    " Vim Dispatch {
        call minpac#add('tpope/vim-dispatch')
        call minpac#add('radenling/vim-dispatch-neovim')
    " }
    " Grepper {
        call minpac#add('mhinz/vim-grepper')
    " }
    " Vim Markdown {
        call minpac#add('godlygeek/tabular')
        call minpac#add('plasticboy/vim-markdown')
        " call minpac#add('iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' })
        call minpac#add('iamcco/markdown-preview.nvim', {'on_ft': ['markdown', 'pandoc.markdown', 'rmd'],
              \ 'build': 'cd app & yarn install' })
    " }

    " General {
        if count(g:spf13_bundle_groups, 'ctrlp')
            call minpac#add('ctrlpvim/ctrlp.vim')
            call minpac#add('tacahiroy/ctrlp-funky')
        endif

        if count(g:spf13_bundle_groups, 'general')
            call minpac#add('scrooloose/nerdtree')
            call minpac#add('altercation/vim-colors-solarized')
            call minpac#add('spf13/vim-colors')
            call minpac#add('tpope/vim-surround')
            call minpac#add('tpope/vim-repeat')
            call minpac#add('rhysd/conflict-marker.vim')
            call minpac#add('jiangmiao/auto-pairs')
            call minpac#add('junegunn/fzf', {'do' : './install --bin'})
            call minpac#add('junegunn/fzf.vim')
            call minpac#add('mileszs/ack.vim')
            call minpac#add('junegunn/seoul256.vim')
            call minpac#add('terryma/vim-multiple-cursors')
            call minpac#add('vim-scripts/sessionman.vim')
            call minpac#add('vim-scripts/matchit.zip')
            if (has("python") || has("python3")) && exists('g:spf13_use_powerline') && !exists('g:spf13_use_old_powerline')
                call minpac#add('Lokaltog/powerline', {'rtp':'/powerline/bindings/vim'} )
            elseif exists('g:spf13_use_powerline') && exists('g:spf13_use_old_powerline')
                call minpac#add('Lokaltog/vim-powerline')
            else
                call minpac#add('vim-airline/vim-airline')
                call minpac#add('vim-airline/vim-airline-themes')
            endif
            call minpac#add('powerline/fonts')
            call minpac#add('bling/vim-bufferline')
            call minpac#add('easymotion/vim-easymotion')
            call minpac#add('jistr/vim-nerdtree-tabs')
            call minpac#add('flazz/vim-colorschemes')
            call minpac#add('mbbill/undotree')
            call minpac#add('nathanaelkane/vim-indent-guides')
            if !exists('g:spf13_no_views')
                call minpac#add('vim-scripts/restore_view.vim')
            endif
            " Automatically set 'shiftwidth' + 'expandtab' (indention) based on file type.
            call minpac#add('tpope/vim-sleuth')
            call minpac#add('mhinz/vim-signify')
            call minpac#add('tpope/vim-abolish')
            call minpac#add('osyo-manga/vim-over')
            call minpac#add('kana/vim-textobj-user')
            call minpac#add('kana/vim-textobj-indent')
            call minpac#add('gcmt/wildfire.vim')
        endif
    " }

    " Writing {
        if count(g:spf13_bundle_groups, 'writing')
            call minpac#add('reedes/vim-litecorrect')
            call minpac#add('reedes/vim-textobj-sentence')
            call minpac#add('reedes/vim-textobj-quote')
            call minpac#add('reedes/vim-wordy')

            " Dim paragraphs above and below the active paragraph.
            call minpac#add('junegunn/limelight.vim')

            " Distraction free writing by removing UI elements and centering everything.
            call minpac#add('junegunn/goyo.vim')
        endif
    " }

    " General Programming {
        if count(g:spf13_bundle_groups, 'programming')
            " Pick one of the checksyntax, jslint, or syntastic
            call minpac#add('scrooloose/syntastic')
            call minpac#add('tpope/vim-fugitive')
            call minpac#add('tpope/vim-rhubarb')
            call minpac#add('delfas/vim-fubitive')
            call minpac#add('mattn/webapi-vim')
            call minpac#add('mattn/gist-vim')
            call minpac#add('scrooloose/nerdcommenter')
            " Toggle comments in various ways
            call minpac#add('tpope/vim-commentary')
            call minpac#add('godlygeek/tabular')
            call minpac#add('luochen1990/rainbow')
            call minpac#add('universal-ctags/ctags')
            if executable('ctags')
                call minpac#add('majutsushi/tagbar')
            endif
            call minpac#add('ludovicchabant/vim-gutentags')

            " Modify * to also work with visual selections.
            call minpac#add('nelstrom/vim-visual-star-search')

            " Automatically clear search highlights after you move your cursor.
            call minpac#add('haya14busa/is.vim')

            " Launch Ranger from Vim.
            call minpac#add('francoiscabrol/ranger.vim')

            " Run a diff on 2 directories.
            call minpac#add('will133/vim-dirdiff')

            " Better display unwanted whitespace.
            call minpac#add('ntpeters/vim-better-whitespace')

            " Drastically improve insert mode performance in files with folds.
            call minpac#add('Konfekt/FastFold')

            " Run test suites for various languages.
            call minpac#add('janko/vim-test')
          endif
    " }

    " Snippets & AutoComplete {
        if count(g:spf13_bundle_groups, 'deoplete')
          if has('nvim')
            call minpac#add('Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' })
          else
            call minpac#add('Shougo/deoplete.nvim')
            call minpac#add('roxma/nvim-yarp')
            call minpac#add('roxma/vim-hug-neovim-rpc')
          endif
        endif

        if count(g:spf13_bundle_groups, 'snipmate')
            call minpac#add('garbas/vim-snipmate')
            call minpac#add('honza/vim-snippets')
            " Source support_function.vim to support vim-snippets.
            if filereadable(expand("~/.vim/pack/minpac/start/vim-snippets/snippets/support_functions.vim"))
                source ~/.vim/pack/minpac/start/vim-snippets/snippets/support_functions.vim
            endif
        elseif count(g:spf13_bundle_groups, 'youcompleteme')
            call minpac#add('Valloric/YouCompleteMe')
            call minpac#add('SirVer/ultisnips')
            call minpac#add('honza/vim-snippets')
        elseif count(g:spf13_bundle_groups, 'neocomplete')
            call minpac#add('Shougo/neocomplete.vim.git')
            call minpac#add('Shougo/neosnippet')
            call minpac#add('Shougo/neosnippet-snippets')
            call minpac#add('honza/vim-snippets')
        endif
    " }

    " PHP {
        if count(g:spf13_bundle_groups, 'php')
            call minpac#add('spf13/PIV')
            call minpac#add('arnaud-lb/vim-php-namespace')
            call minpac#add('beyondwords/vim-twig')
        endif
    " }

    " Python {
        if count(g:spf13_bundle_groups, 'python')
            " Pick either python-mode or pyflakes & pydoc
            call minpac#add('klen/python-mode')
            call minpac#add('yssource/python.vim')
            call minpac#add('python_match.vim')
            call minpac#add('pythoncomplete')
        endif
    " }

    " Typescript {
        if count(g:spf13_bundle_groups, 'typescript')
            call minpac#add('leafgarland/typescript-vim')
        endif
    " }
    "
    "
    " Javascript {
        if count(g:spf13_bundle_groups, 'javascript')
            call minpac#add('elzr/vim-json')
            call minpac#add('groenewege/vim-less')
            call minpac#add('pangloss/vim-javascript')
            call minpac#add('briancollins/vim-jst')
            call minpac#add('kchmck/vim-coffee-script')
        endif
    " }

    " Scala {
        if count(g:spf13_bundle_groups, 'scala')
            call minpac#add('derekwyatt/vim-scala')
            call minpac#add('derekwyatt/vim-sbt')
            call minpac#add('xptemplate')
        endif
    " }

    " Haskell {
        if count(g:spf13_bundle_groups, 'haskell')
            call minpac#add('travitch/hasksyn')
            call minpac#add('dag/vim2hs')
            call minpac#add('Twinside/vim-haskellConceal')
            call minpac#add('Twinside/vim-haskellFold')
            call minpac#add('lukerandall/haskellmode-vim')
            call minpac#add('eagletmt/neco-ghc')
            call minpac#add('eagletmt/ghcmod-vim')
            call minpac#add('Shougo/vimproc.vim')
            call minpac#add('adinapoli/cumino')
            call minpac#add('bitc/vim-hdevtools')
        endif
    " }

    " HTML {
        if count(g:spf13_bundle_groups, 'html')
            call minpac#add('vim-scripts/HTML-AutoCloseTag')
            call minpac#add('hail2u/vim-css3-syntax')
            call minpac#add('gorodinskiy/vim-coloresque')
            call minpac#add('tpope/vim-haml')
            call minpac#add('mattn/emmet-vim')
        endif
    " }

    " Ruby {
        if count(g:spf13_bundle_groups, 'ruby')
            call minpac#add('tpope/vim-rails')
            let g:rubycomplete_buffer_loading = 1
            "let g:rubycomplete_classes_in_global = 1
            "let g:rubycomplete_rails = 1
        endif
    " }

    " Puppet {
        if count(g:spf13_bundle_groups, 'puppet')
            call minpac#add('rodjek/vim-puppet')
        endif
    " }

    " Go Lang {
        if count(g:spf13_bundle_groups, 'go')
            "call minpac#add 'Blackrush/vim-gocode'
            call minpac#add('fatih/vim-go')
        endif
    " }

    " Elixir {
        if count(g:spf13_bundle_groups, 'elixir')
            call minpac#add('elixir-lang/vim-elixir')
            call minpac#add('carlosgaldino/elixir-snippets')
            call minpac#add('mattreduce/vim-mix')
        endif
    " }

    " Misc {
        if count(g:spf13_bundle_groups, 'misc')
            call minpac#add('rust-lang/rust.vim')
            call minpac#add('tpope/vim-markdown')
            call minpac#add('spf13/vim-preview')
            call minpac#add('tpope/vim-cucumber')
            call minpac#add('cespare/vim-toml')
            call minpac#add('quentindecock/vim-cucumber-align-pipes')
            call minpac#add('saltstack/salt-vim')
        endif
    " }

    call minpac#add('w0rp/ale')
    call minpac#add('qpkorr/vim-bufkill')
    call minpac#add('chrisbra/csv.vim')
    call minpac#add('OmniSharp/omnisharp-vim')
    call minpac#add('powerline/fonts')
    call minpac#add('tomtom/tlib_vim')
    call minpac#add('MarcWeber/vim-addon-mw-utils')
    call minpac#add('tpope/vim-unimpaired')


" }
"
"
" Vim UI {
    if !exists('g:override_spf13_bundles') && filereadable(expand("~/.vim/pack/minpac/start/vim-colors-solarized/colors/solarized.vim"))
        let g:solarized_termcolors=256
        let g:solarized_termtrans=1
        let g:solarized_contrast="normal"
        let g:solarized_visibility="normal"
        color solarized             " Load a colorscheme
    endif

    set tabpagemax=15               " Only show 15 tabs
    set showmode                    " Display the current mode

    " Highlight the current line and column
    " Don't do this - It makes window redraws painfully slow
    set nocursorline
    set nocursorcolumn

    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr    " Remove highlight color from current line number

    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        if !exists('g:override_spf13_bundles')
            "set statusline+=%{fugitive#statusline()} " Git Hotness
            " Set the status line the way i like it
            set stl=%f\ %m\ %r%{CustomFugitiveStatusLine()}\ Line:%l/%L[%p%%]\ Col:%v\ Buf:#%n\ [%b][0x%B]
        endif
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif

    "set backspace=2                " allow backspacing over indent, eol, and the start of an insert
    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    " i'm happy to type the case of things.  i tried the ignorecase, smartcase
    " thing but it just wasn't working out for me
    set noignorecase
    "set ignorecase                  " Case insensitive search
    "set smartcase                   " Case sensitive when uc present
    "set wildmenu                    " Make the command-line completion better
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    " When the page starts to scroll, keep the cursor 8 lines from the top and 8
    " lines from the bottom
    set scrolloff=8
    "set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    " show trailing whitespaces
    "set listchars=tab:?\ ,trail:¬,nbsp:.,extends:?,precedes:?
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

    "set t_Co=256
    if has("mac")
      let g:main_font = "Source\\ Code\\ Pro\\ Light:h11"
      let g:small_font = "Source\\ Code\\ Pro\\ Light:h2"
    else
        if has("win32") || has("win64") || has("win16")
          "let g:main_font = Consolas:h11:cANSI
          "let g:small_font = Consolas:h10:cANSI

          let g:main_font = "Source\\ Code\\ Pro\\ for\\ Powerline:h10:cANSI"
          let g:small_font = "Source\\ Code\\ Pro\\ for\\ Powerline:h3:cANSI"
          "let g:main_font = "Ubuntu\\ Mono:h10:cANSI"
          "let g:small_font = "Ubuntu\\ Mono:h3:cANSI"
        else
          let g:main_font = "DejaVu\\ Sans\\ Mono\\ 9"
          let g:small_font = "DejaVu\\ Sans\\ Mono\\ 2"
        endif
    endif

    if has('nvim')
      "set guifont=Consolas:h11:cANSI
      let guifont = "Source\\ Code\\ Pro\\ for\\ Powerline:h10:cANSI"
      "set guifont=Ubuntu\ Mono:h10:cANSI
    elseif has("gui_running")
      if has("gui_gtk2")
        set guifont=Inconsolata\ 12
      elseif has("gui_macvim")
        set guifont=Menlo\ Regular:h14
      elseif has("gui_win32")
        "set guifont=Consolas:h11:cANSI
        set guifont=Ubuntu\ Mono:h10:cANSI
      endif
    endif

    "-----------------------------------------------------------------------------
    " Set up the window colors and size
    "-----------------------------------------------------------------------------
    if has('nvim')
      "set background=light
      colorscheme molokai_dark
      exe "set guifont=" . g:main_font
    elseif has('gui_running') || has('gui_vimr')
      set background=light
      colorscheme molokai_dark
      "colorscheme molokai
      if has('gui_running')
        exe "set guifont=" . g:main_font
        if !exists("g:vimrcloaded")
          winpos 0 0
          if !&diff
            winsize 130 120
          else
            winsize 227 120
          endif
          let g:vimrcloaded = 1
        endif
      endif
    endif
    :nohls

" }

" Formatting {

    set nowrap                      " Do not wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    "set shiftwidth=4                " Use indents of 4 spaces
    set shiftwidth=2
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=2                   " tabstops are 2 spaces
    "set tabstop=4                   " An indentation every four columns
    "set softtabstop=4               " Let backspace delete indent
    set softtabstop=2
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    " Remove trailing whitespaces and ^M chars
    " To disable the stripping of whitespace, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_keep_trailing_whitespace = 1
    autocmd FileType cs,c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:spf13_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " preceding line best in a plugin but here for now.

    autocmd BufNewFile,BufRead *.coffee set filetype=coffee

    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell

    " Switch on syntax highlighting as the last thing that should happen
    syntax on
" }

" Key (re)Mappings {

    " The default leader is '\', but many people prefer ',' as it's in a standard
    " location. To override this behavior and set it back to '\' (or any other
    " character) add the following to your .vimrc.before.local file:
    "   let g:spf13_leader='\'
    if !exists('g:spf13_leader')
        let mapleader = ','
    else
        let mapleader=g:spf13_leader
    endif
    if !exists('g:spf13_localleader')
        let maplocalleader = '_'
    else
        let maplocalleader=g:spf13_localleader
    endif

    " The default mappings for editing and applying the spf13 configuration
    " are <leader>ev and <leader>sv respectively. Change them to your preference
    " by adding the following to your .vimrc.before.local file:
    "   let g:spf13_edit_config_mapping='<leader>ec'
    "   let g:spf13_apply_config_mapping='<leader>sc'
    if !exists('g:spf13_edit_config_mapping')
        let s:spf13_edit_config_mapping = '<leader>ev'
    else
        let s:spf13_edit_config_mapping = g:spf13_edit_config_mapping
    endif
    if !exists('g:spf13_apply_config_mapping')
        let s:spf13_apply_config_mapping = '<leader>sv'
    else
        let s:spf13_apply_config_mapping = g:spf13_apply_config_mapping
    endif

    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    let g:spf13_no_easyWindows = 1
    if !exists('g:spf13_no_easyWindows')
        map <C-J> <C-W>j<C-W>_
        map <C-K> <C-W>k<C-W>_
        map <C-L> <C-W>l<C-W>_
        map <C-H> <C-W>h<C-W>_
    endif

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " End/Start of line motion keys act relative to row/wrap width in the
    " presence of `:set wrap`, and relative to line for `:set nowrap`.
    " Default vim behaviour is to act relative to text line in both cases
    " If you prefer the default behaviour, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_no_wrapRelMotion = 1
    if !exists('g:spf13_no_wrapRelMotion')
        " Same for 0, home, end, etc
        function! WrapRelativeMotion(key, ...)
            let vis_sel=""
            if a:0
                let vis_sel="gv"
            endif
            if &wrap
                execute "normal!" vis_sel . "g" . a:key
            else
                execute "normal!" vis_sel . a:key
            endif
        endfunction

        " Map g* keys in Normal, Operator-pending, and Visual+select
        noremap $ :call WrapRelativeMotion("$")<CR>
        noremap <End> :call WrapRelativeMotion("$")<CR>
        noremap 0 :call WrapRelativeMotion("0")<CR>
        noremap <Home> :call WrapRelativeMotion("0")<CR>
        noremap ^ :call WrapRelativeMotion("^")<CR>
        " Overwrite the operator pending $/<End> mappings from above
        " to force inclusive motion with :execute normal!
        onoremap $ v:call WrapRelativeMotion("$")<CR>
        onoremap <End> v:call WrapRelativeMotion("$")<CR>
        " Overwrite the Visual+select mode mappings from above
        " to ensure the correct vis_sel flag is passed to function
        vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
        vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
        vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
        vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
        vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
    endif

    " The following two lines conflict with moving to top and
    " bottom of the screen
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_no_fastTabs = 1
    if !exists('g:spf13_no_fastTabs')
        map <S-H> gT
        map <S-L> gt
    endif

    " Stupid shift key fixes
    if !exists('g:spf13_no_keyfixes')
        if has("user_commands")
            command! -bang -nargs=* -complete=file E e<bang> <args>
            command! -bang -nargs=* -complete=file W w<bang> <args>
            command! -bang -nargs=* -complete=file Wq wq<bang> <args>
            command! -bang -nargs=* -complete=file WQ wq<bang> <args>
            command! -bang Wa wa<bang>
            command! -bang WA wa<bang>
            command! -bang Q q<bang>
            command! -bang QA qa<bang>
            command! -bang Qa qa<bang>
        endif

        cmap Tabe tabe
    endif

    " Yank from the cursor to the end of the line, to be consistent with C and D.
    nnoremap Y y$

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " Most prefer to toggle search highlighting rather than clear the current
    " search results. To clear search highlighting rather than toggle it on
    " and off, add the following to your .vimrc.before.local file:
    "   let g:spf13_clear_search_highlight = 1
    if exists('g:spf13_clear_search_highlight')
        nmap <silent> <leader>/ :nohlsearch<CR>
    else
        nmap <silent> <leader>/ :set invhlsearch<CR>
    endif
    "nmap <silent> ,n :nohls<CR> " Turn off that stupid highlight search


    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

    " Shortcuts
    " Change Working Directory to that of the current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " cd to the directory containing the file in the buffer
    nmap <silent> ,cd :lcd %:h<CR>
    nmap <silent> ,cr :lcd <c-r>=FindCodeDirOrRoot()<cr><cr>
    nmap <silent> ,md :!bash -c '(mkdir -p %:p:h)'<CR>

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " Visual line repeat
    xnoremap . :normal .<CR>
    xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

    function! ExecuteMacroOverVisualRange()
      echo '@'.getcmdline()
      execute ":'<,'>normal @".nr2char(getchar())
    endfunction

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    " Some helpers to edit mode
    " http://vimcasts.org/e/14
    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    "map zl zL
    "map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip

    " FIXME: Revert this f70be548
    " fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
    map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>

" }
"
" Plugins {
    "
    " Grepper {
       let g:grepper = {}
       let g:grepper.tools = ['grep', 'git', 'rg']

       " Search for the current word
       nnoremap <Leader>* :Grepper -cword -noprompt<CR>

       " Search for the current selection
       nmap gs <plug>(GrepperOperator)
       xmap gs <plug>(GrepperOperator)
       function! SetupCommandAlias(input, output)
         exec 'cabbrev <expr> '.a:input
               \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
               \ .'? ("'.a:output.'") : ("'.a:input.'"))'
       endfunction

       call SetupCommandAlias("grep", "GrepperGrep")

       " Open Grepper-prompt for a particular grep-alike tool
       nnoremap <Leader>g :Grepper -tool git<CR>
       nnoremap <Leader>G :Grepper -tool rg<CR>

       " After searching for text, press this mapping to do a project wide find and
       " replace. It's similar to <leader>r except this one applies to all matches
       " across all files instead of just the current file.
       nnoremap <Leader>R
             \ :let @s='\<'.expand('<cword>').'\>'<CR>
             \ :Grepper -cword -noprompt<CR>
             \ :cfdo %s/<C-r>s//g \| update
             \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>

       " The same as above except it works with a visual selection.
       xmap <Leader>R
             \ "sy
             \ gvgr
             \ :cfdo %s/<C-r>s//g \| update
             \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
    " }
    "
    " GoLang {
        if count(g:spf13_bundle_groups, 'go')
            let g:go_highlight_functions = 1
            let g:go_highlight_methods = 1
            let g:go_highlight_structs = 1
            let g:go_highlight_operators = 1
            let g:go_highlight_build_constraints = 1
            let g:go_fmt_command = "goimports"
            let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
            let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
            au FileType go nmap <Leader>s <Plug>(go-implements)
            au FileType go nmap <Leader>i <Plug>(go-info)
            au FileType go nmap <Leader>e <Plug>(go-rename)
            au FileType go nmap <leader>r <Plug>(go-run)
            au FileType go nmap <leader>b <Plug>(go-build)
            au FileType go nmap <leader>t <Plug>(go-test)
            au FileType go nmap <Leader>gd <Plug>(go-doc)
            au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
            au FileType go nmap <leader>co <Plug>(go-coverage)
        endif
        " }


    " TextObj Sentence {
        if count(g:spf13_bundle_groups, 'writing')
            augroup textobj_sentence
              autocmd!
              autocmd FileType markdown call textobj#sentence#init()
              autocmd FileType textile call textobj#sentence#init()
              autocmd FileType text call textobj#sentence#init()
            augroup END
        endif
    " }

    " TextObj Quote {
        if count(g:spf13_bundle_groups, 'writing')
            augroup textobj_quote
                autocmd!
                autocmd FileType markdown call textobj#quote#init()
                autocmd FileType textile call textobj#quote#init()
                autocmd FileType text call textobj#quote#init({'educate': 0})
            augroup END
        endif
    " }

    " PIV {
        if isdirectory(expand("~/.vim/pack/minpac/start/PIV"))
            let g:DisableAutoPHPFolding = 0
            let g:PIVAutoClose = 0
        endif
    " }

    " Misc {
        if isdirectory(expand("~/.vim/pack/minpac/start/nerdtree"))
            let g:NERDShutUp=1
        endif
        if isdirectory(expand("~/.vim/pack/minpac/start/matchit.zip"))
            let b:match_ignorecase = 1
        endif
    " }

    " OmniComplete {
        " To disable omni complete, add the following to your .vimrc.before.local file:
        "   let g:spf13_no_omni_complete = 1
        if !exists('g:spf13_no_omni_complete')
            if has("autocmd") && exists("+omnifunc")
                autocmd Filetype *
                    \if &omnifunc == "" |
                    \setlocal omnifunc=syntaxcomplete#Complete |
                    \endif
            endif

            hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
            hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
            hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

            " Some convenient mappings
            "inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
            if exists('g:spf13_map_cr_omni_complete')
                inoremap <expr> <CR>     pumvisible() ? "\<C-y>" : "\<CR>"
            endif
            inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
            inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
            inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
            inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

            " Automatically open and close the popup menu / preview window
            au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
            set completeopt=menu,preview,longest
        endif
    " }

    " Ctags {
        "set tags=~/.ctags.d/*.ctags,./.ctags.d/*.ctags

        " Make tags placed in .git/tags file available in all levels of a repository
        let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
        if gitroot != ''
            let &tags = &tags . ',' . gitroot . '/.git/tags'
        endif
    " }

    " AutoCloseTag {
        " Make it so AutoCloseTag works for xml and xhtml files as well
        au FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
        nmap <Leader>ac <Plug>ToggleAutoCloseMappings
    " }

    " SnipMate {
        " Setting the author var
        " If forking, please overwrite in your .vimrc.local file
        let g:snips_author = 'Steve Francia <steve.francia@gmail.com>'
    " }

    " NerdTree {
        if isdirectory(expand("~/.vim/pack/minpac/start/nerdtree"))
            "map <C-e> <plug>NERDTreeTabsToggle<CR>
            map <leader>e :NERDTreeFind<CR>
            nmap <leader>nt :NERDTreeFind<CR>

            let NERDTreeShowBookmarks=1
            let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
            let NERDTreeChDirMode=0
            let NERDTreeQuitOnOpen=1
            let NERDTreeMouseMode=2
            let NERDTreeShowHidden=1
            let g:NERDTreeAutoDeleteBuffer=1
            let NERDTreeKeepTreeInNewTab=1
            let g:nerdtree_tabs_open_on_gui_startup=0

            " Open nerd tree at the current file or close nerd tree if pressed again.
            nnoremap <silent> <expr> <Leader>n g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"
        endif
    " }

    " Tabularize {
        if isdirectory(expand("~/.vim/pack/minpac/start/tabular"))
            nmap <Leader>a& :Tabularize /&<CR>
            vmap <Leader>a& :Tabularize /&<CR>
            nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            nmap <Leader>a=> :Tabularize /=><CR>
            vmap <Leader>a=> :Tabularize /=><CR>
            nmap <Leader>a: :Tabularize /:<CR>
            vmap <Leader>a: :Tabularize /:<CR>
            nmap <Leader>a:: :Tabularize /:\zs<CR>
            vmap <Leader>a:: :Tabularize /:\zs<CR>
            nmap <Leader>a, :Tabularize /,<CR>
            vmap <Leader>a, :Tabularize /,<CR>
            nmap <Leader>a,, :Tabularize /,\zs<CR>
            vmap <Leader>a,, :Tabularize /,\zs<CR>
            nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
            vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
        endif
    " }

    " Session List {
        let g:session_directory = "~/.vim/session"
        let g:session_autoload = "no"
        let g:session_autosave = "no"
        let g:session_command_aliases = 1

        set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
        if isdirectory(expand("~/.vim/pack/minpac/start/sessionman.vim/"))
            nmap <leader>sl :SessionList<CR>
            nmap <leader>ss :SessionSave<CR>
            nmap <leader>sc :SessionClose<CR>
        endif
    " }

    " JSON {
        nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
        let g:vim_json_syntax_conceal = 0
    " }

    " PyMode {
        " Disable if python support not present
        if !has('python') && !has('python3')
            let g:pymode = 0
        endif

        if isdirectory(expand("~/.vim/pack/minpac/start/python-mode"))
            let g:pymode_lint_checkers = ['pyflakes']
            let g:pymode_trim_whitespaces = 0
            let g:pymode_options = 0
            let g:pymode_rope = 0
        endif
    " }


    "
    " ctrlp {
        if count(g:spf13_bundle_groups, 'ctrlp') && isdirectory(expand("~/.vim/pack/minpac/start/ctrlp.vim/"))
            let g:ctrlp_regexp = 1
            let g:ctrlp_switch_buffer = 'E'
            let g:ctrlp_tabpage_position = 'c'
            let g:ctrlp_working_path_mode = 'ra'
            "let g:ctrlp_working_path_mode = 'rc'
            let g:ctrlp_root_markers = ['.project.root']
            "let g:ctrlp_user_command = 'find %s -type f | grep -v -E "\.idea/|\.git/|/build/|/project/project|/target/config-classes|/target/docker|/target/k8s|/target/protobuf_external|/target/scala-2\.[0-9]*/api|/target/scala-2\.[0-9]*/classes|/target/scala-2\.[0-9]*/e2etest-classes|/target/scala-2\.[0-9]*/it-classes|/target/scala-2\.[0-9]*/resolution-cache|/target/scala-2\.[0-9]*/sbt-0.13|/target/scala-2\.[0-9]*/test-classes|/target/streams|/target/test-reports|/target/universal|\.jar$"'
            let g:ctrlp_max_depth = 30
            let g:ctrlp_max_files = 0
            let g:ctrlp_open_new_file = 'r'
            let g:ctrlp_open_multiple_files = '1ri'
            let g:ctrlp_match_window = 'max:40'
            let g:ctrlp_prompt_mappings = {
                  \ 'PrtSelectMove("j")':   ['<c-n>'],
                  \ 'PrtSelectMove("k")':   ['<c-p>'],
                  \ 'PrtHistory(-1)':       ['<c-j>', '<down>'],
                  \ 'PrtHistory(1)':        ['<c-i>', '<up>']
                  \ }

            nmap ,fb :CtrlPBuffer<cr>
            nmap ,ff :CtrlP .<cr>
            nmap ,fF :execute ":CtrlP " . expand('%:p:h')<cr>
            nmap ,fr :call LaunchForThisGitProject("CtrlP")<cr>
            nmap ,fm :CtrlPMixed<cr>

            nnoremap <silent> <D-t> :CtrlP<CR>
            nnoremap <silent> <D-r> :CtrlPMRU<CR>
            let g:ctrlp_custom_ignore = {
                \ 'dir':  '\.git$\|\.hg$\|\.svn$',
                \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

            if executable('ag')
                let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
            elseif executable('ack-grep')
                let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
            elseif executable('ack')
                let s:ctrlp_fallback = 'ack %s --nocolor -f'
            " On Windows use "dir" as fallback command.
            elseif WINDOWS()
                let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
            else
                let s:ctrlp_fallback = 'find %s -type f'
            endif
            if exists("g:ctrlp_user_command")
                unlet g:ctrlp_user_command
            endif
            let g:ctrlp_user_command = {
                \ 'types': {
                    \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
                    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
                \ },
                \ 'fallback': s:ctrlp_fallback
            \ }

            if isdirectory(expand("~/.vim/pack/minpac/start/ctrlp-funky/"))
                " CtrlP extensions
                let g:ctrlp_extensions = ['funky']

                "funky
                nnoremap <Leader>fu :CtrlPFunky<Cr>
            endif
        endif
    "}

    " TagBar {
        if isdirectory(expand("~/.vim/pack/minpac/start/tagbar/"))
            nnoremap <silent> <leader>tt :TagbarToggle<CR>
        endif
    "}

    " Rainbow {
        if isdirectory(expand("~/.vim/pack/minpac/start/rainbow/"))
            let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
        endif
    "}

    " Rhubarb {
        if isdirectory(expand("~/.vim/pack/minpac/start/vim-rhubarb/"))
            let g:github_enterprise_urls = ['https://github.com', 'https://bitbucket.solarwinds.com']
        endif
    " }
    "
    " Fugitive {
        if isdirectory(expand("~/.vim/pack/minpac/start/vim-fugitive/"))
            nnoremap <silent> <leader>gs :Gstatus<CR>
            nnoremap <silent> <leader>gd :Gdiff<CR>
            nnoremap <silent> <leader>gc :Gcommit<CR>
            nnoremap <silent> <leader>gb :Gblame<CR>
            nnoremap <silent> <leader>gl :Glog<CR>
            nnoremap <silent> <leader>gp :Git push<CR>
            nnoremap <silent> <leader>gr :Gread<CR>
            nnoremap <silent> <leader>gw :Gwrite<CR>
            nnoremap <silent> <leader>ge :Gedit<CR>
            " Mnemonic _i_nteractive
            nnoremap <silent> <leader>gi :Git add -p %<CR>
            nnoremap <silent> <leader>gg :SignifyToggle<CR>

        endif
    "}

    " YouCompleteMe {
        if count(g:spf13_bundle_groups, 'youcompleteme')
            let g:acp_enableAtStartup = 0

            " enable completion from tags
            let g:ycm_collect_identifiers_from_tags_files = 1

            " remap Ultisnips for compatibility for YCM
            let g:UltiSnipsExpandTrigger = '<C-j>'
            let g:UltiSnipsJumpForwardTrigger = '<C-j>'
            let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

            " Enable omni completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

            " Haskell post write lint and check with ghcmod
            " $ `cabal install ghcmod` if missing and ensure
            " ~/.cabal/bin is in your $PATH.
            if !executable("ghcmod")
                autocmd BufWritePost *.hs GhcModCheckAndLintAsync
            endif

            " For snippet_complete marker.
            if !exists("g:spf13_no_conceal")
                if has('conceal')
                    set conceallevel=2 concealcursor=i
                endif
            endif

            " Disable the neosnippet preview candidate window
            " When enabled, there can be too much visual noise
            " especially when splits are used.
            set completeopt-=preview
        endif
    " }

    "
    " deoplete {
        if count(g:spf13_bundle_groups, 'deoplete')

            let g:deoplete#enable_at_startup = 1
            let g:python3_host_prog = 'python3'
            let g:python_host_prog = 'python'
            let g:acp_enableAtStartup = 0
            let g:deoplete#enable_at_startup = 1
            let g:deoplete#enable_smart_case = 1
            let g:deoplete#enable_auto_delimiter = 1
            let g:deoplete#max_list = 15
            let g:deoplete#force_overwrite_completefunc = 1


            " Define dictionary.
            let g:deoplete#sources#dictionary#dictionaries = {
                        \ 'default' : '',
                        \ 'vimshell' : $HOME . '/.vimshell_hist',
                        \ 'scheme' : $HOME . '/.gosh_completions'
                        \ }

            " Define keyword.
            if !exists('g:deoplete#keyword_patterns')
                let g:deoplete#keyword_patterns = {}
            endif
            let g:deoplete#keyword_patterns['default'] = '\h\w*'

            " Plugin key-mappings {
                " These two lines conflict with the default digraph mapping of <C-K>
                if !exists('g:spf13_no_neosnippet_expand')
                    imap <C-k> <Plug>(neosnippet_expand_or_jump)
                    smap <C-k> <Plug>(neosnippet_expand_or_jump)
                endif
                if exists('g:spf13_noninvasive_completion')
                    inoremap <CR> <CR>
                    " <ESC> takes you out of insert mode
                    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
                    " <CR> accepts first, then sends the <CR>
                    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                    " <Down> and <Up> cycle like <Tab> and <S-Tab>
                    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
                    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
                    " Jump up and down the list
                    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
                    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
                else
                    " <C-k> Complete Snippet
                    " <C-k> Jump to next snippet point
                    imap <silent><expr><C-k> neosnippet#expandable() ?
                                \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
                                \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
                    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

                    inoremap <expr><C-g> deoplete#undo_completion()
                    inoremap <expr><C-l> deoplete#complete_common_string()
                    "inoremap <expr><CR> deoplete#complete_common_string()

                    " <CR>: close popup
                    " <s-CR>: close popup and save indent.
                    inoremap <expr><s-CR> pumvisible() ? deoplete#smart_close_popup()."\<CR>" : "\<CR>"

                    function! CleverCr()
                        if pumvisible()
                            if neosnippet#expandable()
                                let exp = "\<Plug>(neosnippet_expand)"
                                return exp . deoplete#smart_close_popup()
                            else
                                return deoplete#smart_close_popup()
                            endif
                        else
                            return "\<CR>"
                        endif
                    endfunction

                    " <CR> close popup and save indent or expand snippet
                    imap <expr> <CR> CleverCr()
                    " <C-h>, <BS>: close popup and delete backword char.
                    inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"
                    inoremap <expr><C-y> deoplete#smart_close_popup()
                endif
                " <TAB>: completion.
                inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

                " Courtesy of Matteo Cavalleri

                function! CleverTab()
                    if pumvisible()
                        return "\<C-n>"
                    endif
                    let substr = strpart(getline('.'), 0, col('.') - 1)
                    let substr = matchstr(substr, '[^ \t]*$')
                    if strlen(substr) == 0
                        " nothing to match on empty string
                        return "\<Tab>"
                    else
                        " existing text matching
                        if neosnippet#expandable_or_jumpable()
                            return "\<Plug>(neosnippet_expand_or_jump)"
                        else
                            return deoplete#start_manual_complete()
                        endif
                    endif
                endfunction

                imap <expr> <Tab> CleverTab()
            " }

            " Enable heavy omni completion.
            if !exists('g:deoplete#sources#omni#input_patterns')
                let g:deoplete#sources#omni#input_patterns = {}
            endif
            let g:deoplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
            let g:deoplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
            let g:deoplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
            let g:deoplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
            let g:deoplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'

            " call deoplete#custom#option('sources', {'cs': ['omnisharp'], })
    " }
    " neocomplete {
        elseif count(g:spf13_bundle_groups, 'neocomplete')
            let g:acp_enableAtStartup = 0
            let g:neocomplete#enable_at_startup = 1
            let g:neocomplete#enable_smart_case = 1
            let g:neocomplete#enable_auto_delimiter = 1
            let g:neocomplete#max_list = 15
            let g:neocomplete#force_overwrite_completefunc = 1


            " Define dictionary.
            let g:neocomplete#sources#dictionary#dictionaries = {
                        \ 'default' : '',
                        \ 'vimshell' : $HOME . '/.vimshell_hist',
                        \ 'scheme' : $HOME . '/.gosh_completions'
                        \ }

            " Define keyword.
            if !exists('g:neocomplete#keyword_patterns')
                let g:neocomplete#keyword_patterns = {}
            endif
            let g:neocomplete#keyword_patterns['default'] = '\h\w*'

            " Plugin key-mappings {
                " These two lines conflict with the default digraph mapping of <C-K>
                if !exists('g:spf13_no_neosnippet_expand')
                    imap <C-k> <Plug>(neosnippet_expand_or_jump)
                    smap <C-k> <Plug>(neosnippet_expand_or_jump)
                endif
                if exists('g:spf13_noninvasive_completion')
                    inoremap <CR> <CR>
                    " <ESC> takes you out of insert mode
                    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
                    " <CR> accepts first, then sends the <CR>
                    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                    " <Down> and <Up> cycle like <Tab> and <S-Tab>
                    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
                    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
                    " Jump up and down the list
                    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
                    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
                else
                    " <C-k> Complete Snippet
                    " <C-k> Jump to next snippet point
                    imap <silent><expr><C-k> neosnippet#expandable() ?
                                \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
                                \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
                    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

                    inoremap <expr><C-g> neocomplete#undo_completion()
                    inoremap <expr><C-l> neocomplete#complete_common_string()
                    "inoremap <expr><CR> neocomplete#complete_common_string()

                    " <CR>: close popup
                    " <s-CR>: close popup and save indent.
                    inoremap <expr><s-CR> pumvisible() ? neocomplete#smart_close_popup()."\<CR>" : "\<CR>"

                    function! CleverCr()
                        if pumvisible()
                            if neosnippet#expandable()
                                let exp = "\<Plug>(neosnippet_expand)"
                                return exp . neocomplete#smart_close_popup()
                            else
                                return neocomplete#smart_close_popup()
                            endif
                        else
                            return "\<CR>"
                        endif
                    endfunction

                    " <CR> close popup and save indent or expand snippet
                    imap <expr> <CR> CleverCr()
                    " <C-h>, <BS>: close popup and delete backword char.
                    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
                    inoremap <expr><C-y> neocomplete#smart_close_popup()
                endif
                " <TAB>: completion.
                inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

                " Courtesy of Matteo Cavalleri

                function! CleverTab()
                    if pumvisible()
                        return "\<C-n>"
                    endif
                    let substr = strpart(getline('.'), 0, col('.') - 1)
                    let substr = matchstr(substr, '[^ \t]*$')
                    if strlen(substr) == 0
                        " nothing to match on empty string
                        return "\<Tab>"
                    else
                        " existing text matching
                        if neosnippet#expandable_or_jumpable()
                            return "\<Plug>(neosnippet_expand_or_jump)"
                        else
                            return neocomplete#start_manual_complete()
                        endif
                    endif
                endfunction

                imap <expr> <Tab> CleverTab()
            " }

            " Enable heavy omni completion.
            if !exists('g:neocomplete#sources#omni#input_patterns')
                let g:neocomplete#sources#omni#input_patterns = {}
            endif
            let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
            let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
    " }
    " Normal Vim omni-completion {
    " To disable omni complete, add the following to your .vimrc.before.local file:
    "   let g:spf13_no_omni_complete = 1
        elseif !exists('g:spf13_no_omni_complete')
            " Enable omni-completion.
            autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

        endif
    " }

    " Snippets {
        if count(g:spf13_bundle_groups, 'neocomplete')

            " Use honza's snippets.
            let g:neosnippet#snippets_directory='~/.vim/pack/minpac/start/neosnippet-snippets/neosnippets/'

            " Enable neosnippet snipmate compatibility mode
            let g:neosnippet#enable_snipmate_compatibility = 1

            " For snippet_complete marker.
            if !exists("g:spf13_no_conceal")
                if has('conceal')
                    set conceallevel=2 concealcursor=i
                endif
            endif

            " Enable neosnippets when using go
            let g:go_snippet_engine = "neosnippet"

            " Disable the neosnippet preview candidate window
            " When enabled, there can be too much visual noise
            " especially when splits are used.
            set completeopt-=preview
        endif
    " }

    " FIXME: Isn't this for Syntastic to handle?
    " Haskell post write lint and check with ghcmod
    " $ `cabal install ghcmod` if missing and ensure
    " ~/.cabal/bin is in your $PATH.
    if !executable("ghcmod")
        autocmd BufWritePost *.hs GhcModCheckAndLintAsync
    endif

    " UndoTree {
        if isdirectory(expand("~/.vim/pack/minpac/start/undotree/"))
            nnoremap <Leader>u :UndotreeToggle<CR>
            " If undotree is opened, it is likely one wants to interact with it.
            let g:undotree_SetFocusWhenToggle=1
        endif
    " }

    " indent_guides {
        if isdirectory(expand("~/.vim/pack/minpac/start/vim-indent-guides/"))
            let g:indent_guides_start_level = 2
            let g:indent_guides_guide_size = 1
            let g:indent_guides_enable_on_vim_startup = 1
            let g:indent_guides_color_change_percent = 1.1
        endif
    " }

    " Wildfire {
    let g:wildfire_objects = {
                \ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip"],
                \ "html,xml" : ["at"],
                \ }
    " }

    "
    " vim-airline {
        " Set configuration options for the statusline plugin vim-airline.
        " Use the powerline theme and optionally enable powerline symbols.
        " To use the symbols , , , , , , and .in the statusline
        " segments add the following to your .vimrc.before.local file:
        "   let g:airline_powerline_fonts=1
        " If the previous symbols do not render for you then install a
        " powerline enabled font.
        let g:airline_powerline_fonts=1
        if !exists("g:airline_symbols")
          let g:airline_symbols = {}
        endif
        let g:airline_theme                           = "solarized"
        let g:airline#extensions#branch#empty_message = "no .git"
        let g:airline#extensions#whitespace#enabled   = 1
        let g:airline#extensions#syntastic#enabled    = 1
        let g:airline#extensions#tabline#enabled      = 1

        " unicode symbols
        "let g:airline_left_sep = '»'
        "let g:airline_left_sep = '▶'
        "let g:airline_right_sep = '«'
        "let g:airline_right_sep = '◀'
        "let g:airline_symbols.linenr = '␊'
        "let g:airline_symbols.linenr = '␤'
        "let g:airline_symbols.linenr = '¶'
        "let g:airline_symbols.branch = '⎇'
        "let g:airline_symbols.paste = 'ρ'
        "let g:airline_symbols.paste = 'Þ'
        "let g:airline_symbols.paste = '∥'
        "let g:airline_symbols.whitespace = 'Ξ'

        " airline symbols
        "let g:airline_left_sep = '⮀'
        "let g:airline_left_alt_sep = '⮁'
        "let g:airline_right_sep = '⮂'
        "let g:airline_right_alt_sep = '⮃'
        "let g:airline_symbols.branch = '⭠'
        "let g:airline_symbols.readonly = '⭤'
        "let g:airline_symbols.linenr = '⭡'"

        " See `:echo g:airline_theme_map` for some more choices
        " Default in terminal vim is 'dark'
        if isdirectory(expand("~/.vim/pack/minpac/start/vim-airline-themes/"))
            if !exists('g:airline_theme')
                let g:airline_theme = 'solarized'
            endif
            if !exists('g:airline_powerline_fonts')
                " Use the default set of separators with a few customizations
                let g:airline_left_sep='›'  " Slightly fancier than '>'
                let g:airline_right_sep='‹' " Slightly fancier than '<'
            endif
        endif
    " }
    " {
        let g:ale_linters = { 'cs': ['OmniSharp'] }

        augroup omnisharp_commands
            autocmd!

            " When Syntastic is available but not ALE, automatic syntax check on events
            " (TextChanged requires Vim 7.4)
            " autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

            " Show type information automatically when the cursor stops moving
            autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()

            " The following commands are contextual, based on the cursor position.
            autocmd FileType cs nnoremap <buffer> gd :OmniSharpGotoDefinition<CR>
            autocmd FileType cs nnoremap <buffer> <Leader>fi :OmniSharpFindImplementations<CR>
            autocmd FileType cs nnoremap <buffer> <Leader>fs :OmniSharpFindSymbol<CR>
            autocmd FileType cs nnoremap <buffer> <Leader>fu :OmniSharpFindUsages<CR>

            " Finds members in the current buffer
            autocmd FileType cs nnoremap <buffer> <Leader>fm :OmniSharpFindMembers<CR>

            autocmd FileType cs nnoremap <buffer> <Leader>fx :OmniSharpFixUsings<CR>
            autocmd FileType cs nnoremap <buffer> <Leader>tt :OmniSharpTypeLookup<CR>
            autocmd FileType cs nnoremap <buffer> <Leader>dc :OmniSharpDocumentation<CR>
            autocmd FileType cs nnoremap <buffer> <C-\> :OmniSharpSignatureHelp<CR>
            autocmd FileType cs inoremap <buffer> <C-\> <C-o>:OmniSharpSignatureHelp<CR>


            " Navigate up and down by method/property/field
            autocmd FileType cs nnoremap <buffer> <C-k> :OmniSharpNavigateUp<CR>
            autocmd FileType cs nnoremap <buffer> <C-j> :OmniSharpNavigateDown<CR>
        augroup END

        " Contextual code actions (uses fzf, CtrlP or unite.vim when available)
        nnoremap <Leader><Space> :OmniSharpGetCodeActions<CR>
        " Run code actions with text selected in visual mode to extract method
        xnoremap <Leader><Space> :call OmniSharp#GetCodeActions('visual')<CR>

        " Rename with dialog
        nnoremap <Leader>nm :OmniSharpRename<CR>
        nnoremap <F2> :OmniSharpRename<CR>
        " Rename without dialog - with cursor on the symbol to rename: `:Rename newname`
        command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

        nnoremap <Leader>cf :OmniSharpCodeFormat<CR>

        " Start the omnisharp server for the current solution
        nnoremap <Leader>ss :OmniSharpStartServer<CR>
        nnoremap <Leader>sp :OmniSharpStopServer<CR>

        " Add syntax highlighting for types and interfaces
        nnoremap <Leader>th :OmniSharpHighlightTypes<CR>

        " Enable snippet completion
        let g:OmniSharp_want_snippet=1
    "
    " }
" }

" printing options
set printoptions=header:0,duplex:long,paper:letter

" set the search scan to wrap lines
set wrapscan

" make command line two lines high
set ch=2

" set visual bell -- i hate that damned beeping
set vb

" Set desired preview window height for viewing documentation.
" You might also want to look at the echodoc plugin.
set previewheight=5

" Alright... let's try this out
imap jj <esc>
cmap jj <esc>

" I like jj - Let's try something else fun
imap ,fn <c-r>=expand('%:t:r')<cr>

" Add a GUID to the current line
imap <C-J>d <C-r>=substitute(system("uuidgen"), '.$', '', 'g')<CR>

" Toggle fullscreen mode
nmap <silent> <F3> :call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>

" Underline the current line with '='
nmap <silent> ,u= :t.\|s/./=/g\|:nohls<cr>
nmap <silent> ,u- :t.\|s/./-/g\|:nohls<cr>
nmap <silent> ,u~ :t.\|s/./\\~/g\|:nohls<cr>

" Shrink the current window to fit the number of lines in the buffer.  Useful
" for those buffers that are only a few lines
nmap <silent> ,sw :execute ":resize " . line('$')<cr>

" Use the bufkill plugin to eliminate a buffer but keep the window layout
nmap ,bd :BD<cr>
nmap ,bw :BW<cr>
" Make horizontal scrolling easier
nmap <silent> <C-o> 10zl
nmap <silent> <C-i> 10zh
"
" set text wrapping toggles
"nmap <silent> <c-/> <Plug>WimwikiIndex
nmap <silent> ,ww :set invwrap<cr>
nmap <silent> ,wW :windo set invwrap<cr>
" Maps to make handling windows a bit easier
noremap <silent> ,h :wincmd h<CR>
noremap <silent> ,j :wincmd j<CR>
noremap <silent> ,k :wincmd k<CR>
noremap <silent> ,l :wincmd l<CR>
noremap <silent> ,sb :wincmd p<CR>

noremap <silent> <C-F9>  :vertical resize -10<CR>
noremap <silent> <C-F10> :resize +10<CR>
noremap <silent> <C-F11> :resize -10<CR>
noremap <silent> <C-F12> :vertical resize +10<CR>

noremap <silent> ,s8 :vertical resize 83<CR>

noremap <silent> ,cj :wincmd j<CR>:close<CR>
noremap <silent> ,ck :wincmd k<CR>:close<CR>
noremap <silent> ,ch :wincmd h<CR>:close<CR>
noremap <silent> ,cl :wincmd l<CR>:close<CR>

noremap <silent> ,cc :close<CR>
noremap <silent> ,cw :cclose<CR>

noremap <silent> ,ml <C-W>L
noremap <silent> ,mk <C-W>K
noremap <silent> ,mh <C-W>H
noremap <silent> ,mj <C-W>J

noremap <silent> <C-7> <C-W>>
noremap <silent> <C-8> <C-W>+
noremap <silent> <C-9> <C-W>+
noremap <silent> <C-0> <C-W>>

" I don't like it when the matching parens are automatically highlighted
let loaded_matchparen = 1

" togglables without FN keys
nnoremap <leader>1 :GundoToggle<CR>
set pastetoggle=<leader>2
nnoremap <leader>3 :TlistToggle<CR>
nnoremap <leader>4 :TagbarToggle<CR>
nnoremap <leader>5 :NERDTreeToggle<CR>

" visual reselect of just pasted
nnoremap gp `[v`]

"make enter break and do newlines
nnoremap <CR> O<Esc>j
nnoremap <leader>j i<CR><Esc>==

"make space in normal mode add space
nnoremap <Space> i<Space><Esc>l

" better scrolling
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>

" consistent menu navigation
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>

" intellij style autocomplete shortcut
inoremap <C-@> <C-x><C-o>
inoremap <C-Space> <C-x><C-o>

" reload all open buffers
nnoremap <leader>Ra :tabdo exec "windo e!"

"map next-previous jumps
nnoremap <leader>m <C-o>
nnoremap <leader>. <C-i>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Use sane regexes
"nnoremap <leader>/ /\v
"vnoremap <leader>/ /\v

" Use :Subvert search
nnoremap <leader>// :S /
vnoremap <leader>// :S /

" Use regular replace
nnoremap <leader>s :%s /
vnoremap <leader>s :%s /

" Use :Subvert replace
nnoremap <leader>S :%S /
vnoremap <leader>S :%S /

" clever-f prompt
let g:clever_f_show_prompt = 1
let g:clever_f_across_no_line = 1

function! Solarized8Contrast(delta)
  let l:schemes = map(['_low', '_flat', '', '_high'], '"solarized8_".(&background).v:val')
  exe 'colors' l:schemes[((a:delta+index(l:schemes, g:colors_name)) % 4 + 4) % 4]
endfunction

nmap <leader>- :<c-u>call Solarized8Contrast(-v:count1)<cr>
nmap <leader>+ :<c-u>call Solarized8Contrast(+v:count1)<cr>

function! CustomFugitiveStatusLine()
  let status = fugitive#statusline()
  let trimmed = substitute(status, '\[Git(\(.*\))\]', '\1', '')
  let trimmed = substitute(trimmed, '\(\w\)\w\+[_/]\ze', '\1/', '')
  let trimmed = substitute(trimmed, '/[^_]*\zs_.*', '', '')
  if len(trimmed) == 0
    return ""
  else
    return '(' . trimmed[0:10] . ')'
  endif
endfunction

" Fix the & command in normal+visual modes {{{2
nnoremap & :&&<Enter>
xnoremap & :&&<Enter>

" Strip trailing whitespace {{{2
function! Preserve(command)
  let l:save = winsaveview()
  execute a:command
  call winrestview(l:save)
endfunction

command! TrimWhitespace call Preserve("%s/\\s\\+$//e")
nmap _$ :TrimWhitespace<CR>


" Set the status line the way i like it
" set stl=%f\ %m\ %r%{CustomFugitiveStatusLine()}\ Line:%l/%L[%p%%]\ Col:%v\ Buf:#%n\ [%b][0x%B]
function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'

  return '[%n] %f %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
endfunction

let &statusline = s:statusline_expr()

" tell VIM to always put a status line in, even if there is only one window
set laststatus=2

" Don't update the display while executing macros
set lazyredraw

" Don't show the current command in the lower right corner.  In OSX, if this is
" set and lazyredraw is set then it's slow as molasses, so we unset this
set noshowcmd

set ruler

" Show the current mode
set showmode




" Set up the gui cursor to look nice
set guicursor=n-v-c:block-Cursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor,r-cr:hor20-Cursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175

" set the gui options the way I like
set guioptions=acg

" Setting this below makes it sow that error messages don't disappear after one second on startup.
"set debug=msg

" This is the timeout used while waiting for user input on a multi-keyed macro
" or while just sitting and waiting for another key to be pressed measured
" in milliseconds.
"
" i.e. for the ",d" command, there is a "timeoutlen" wait period between the
"      "," key and the "d" key.  If the "d" key isn't pressed before the
"      timeout expires, one of two things happens: The "," command is executed
"      if there is one (which there isn't) or the command aborts.
set timeoutlen=500


set foldlevelstart=99
" These commands open folds
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo



" Disable encryption (:X)
"set key=

" Same as default except that I remove the 'u' option
set complete=.,w,b,t

" When completing by tag, show the whole tag, not just the function name
set showfulltag

" Disable it... every time I hit the limit I unset this anyway. It's annoying
set textwidth=0

" get rid of the silly characters in separators
set fillchars = ""

" Add ignorance of whitespace to diff
set diffopt=iwhite,filler,vertical

" Automatically read a file that has changed on disk
set autoread

set grepprg=grep\ -nH\ $*

" Trying out the line numbering thing... never liked it, but that doesn't mean
" I shouldn't give it another go :)
set number
set relativenumber

" Types of files to ignore when autocompleting things
set wildignore+=*.o,*.class,*.git,*.svn

" Various characters are "wider" than normal fixed width characters, but the
" default setting of ambiwidth (single) squeezes them into "normal" width, which
" sucks.  Setting it to double makes it awesome.
set ambiwidth=single

" OK, so I'm gonna remove the VIM safety net for a while and see if kicks my ass
set nobackup
set nowritebackup
set noswapfile

" Wipe out all buffers
nmap <silent> ,wa :call BWipeoutAll()<cr>

" Toggle paste mode
nmap <silent> ,p :set invpaste<CR>:set paste?<CR>

" Cycle through splits.
nnoremap <S-Tab> <C-w>w

" put the vim directives for my file editing settings in
nmap <silent> ,vi ovim:set ts=2 sts=2 sw=2:<CR>vim600:fdm=marker fdl=1 fdc=0:<ESC>

" The following beast is something i didn't write... it will return the
" syntax highlighting group that the current "thing" under the cursor
" belongs to -- very useful for figuring out what to change as far as
" syntax highlighting goes.
nmap <silent> ,qq :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Press * to search for the term under the cursor or a visual selection and
" then press a key below to replace all instances of it in the current file.
nnoremap <Leader>r :%s///g<Left><Left>
nnoremap <Leader>rc :%s///gc<Left><Left><Left>

" The same as above but instead of acting on the whole file it will be
" restricted to the previously visually selected range. You can do that by
" pressing *, visually selecting the range you want it to apply to and then
" press a key below to replace all instances of it in the current selection.
xnoremap <Leader>r :s///g<Left><Left>
xnoremap <Leader>rc :s///gc<Left><Left><Left>

" Type a replacement term and press . to repeat the replacement again. Useful
" for replacing a few instances of the term (comparable to multiple cursors).
nnoremap <silent> s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent> s* "sy:let @/=@s<CR>cgn

" Clear search highlights.
" map <Leader><Space> :let @/=''<CR>

" Toggle quickfix window.
function! QuickFix_toggle()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            cclose
            return
        endif
    endfor

    copen
endfunction
nnoremap <silent> <Leader>c :call QuickFix_toggle()<CR>

" Prevent x from overriding what's in the clipboard.
noremap x "_x
noremap X "_x

" Prevent selecting and pasting from overwriting what you originally copied.
xnoremap p pgvy

" Keep cursor at the bottom of the visual selection after you yank it.
vmap y ygv<Esc>

" set text wrapping toggles
"nmap <silent> <c-/> <Plug>WimwikiIndex
nmap <silent> ,ww :set invwrap<cr>
nmap <silent> ,wW :windo set invwrap<cr>

runtime! macros/matchit.vim

" allow command line editing like emacs
cnoremap <C-A>      <Home>
cnoremap <C-B>      <Left>
cnoremap <C-E>      <End>
cnoremap <C-F>      <Right>
cnoremap <C-N>      <End>
cnoremap <C-P>      <Up>
cnoremap <ESC>b     <S-Left>
cnoremap <ESC><C-B> <S-Left>
cnoremap <ESC>f     <S-Right>
cnoremap <ESC><C-F> <S-Right>
cnoremap <ESC><C-H> <C-W>

" Make the current file executable
nmap ,x :w<cr>:!chmod 755 %<cr>:e<cr>

" Digraphs
" Alpha
imap <c-l><c-a> <c-k>a*
" Beta
imap <c-l><c-b> <c-k>b*
" Gamma
imap <c-l><c-g> <c-k>g*
" Delta
imap <c-l><c-d> <c-k>d*
" Epslion
imap <c-l><c-e> <c-k>e*
" Lambda
imap <c-l><c-l> <c-k>l*
" Eta
imap <c-l><c-y> <c-k>y*
" Theta
imap <c-l><c-h> <c-k>h*
" Mu
imap <c-l><c-m> <c-k>m*
" Rho
imap <c-l><c-r> <c-k>r*
" Pi
imap <c-l><c-p> <c-k>p*
" Phi
imap <c-l><c-f> <c-k>f*

function! ClearText(type, ...)
	let sel_save = &selection
	let &selection = "inclusive"
	let reg_save = @@
	if a:0 " Invoked from Visual mode, use '< and '> marks
		silent exe "normal! '<" . a:type . "'>r w"
	elseif a:type == 'line'
		silent exe "normal! '[V']r w"
	elseif a:type == 'line'
		silent exe "normal! '[V']r w"
    elseif a:type == 'block'
      silent exe "normal! `[\<C-V>`]r w"
    else
      silent exe "normal! `[v`]r w"
    endif
    let &selection = sel_save
    let @@ = reg_save
endfunction

" Syntax coloring lines that are too long just slows down the world

set synmaxcol=2048

" syntastic {{{2
let g:syntastic_mode_map = {
      \ 'mode': 'passive',
      \ 'active_filetypes': [
      \   'javascript'
      \ ],
      \ 'passive_filetypes': [
      \   'html',
      \   'ruby'
      \ ]
      \ }
let g:syntastic_ruby_checkers=['bx rubocop', 'mri']"

"-----------------------------------------------------------------------------
" Fugitive
"-----------------------------------------------------------------------------
" Thanks to Drew Neil
autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \  noremap <buffer> .. :edit %:h<cr> |
  \ endif
autocmd BufReadPost fugitive://* set bufhidden=delete

:command! Gammend :Gcommit --amend

nmap ,gs :Gstatus<cr>
nmap ,ge :Gedit<cr>
nmap ,gw :Gwrite<cr>
nmap ,gr :Gread<cr>

"-----------------------------------------------------------------------------
" Branches and Tags
"-----------------------------------------------------------------------------
let g:last_known_branch = {}

function! HasGitRepo(path)
  let hasgit = 'bash -c ''(cd ' . a:path . '; git rev-parse --show-toplevel 2>/dev/null )'''
  let result = system(hasgit)
  if result =~# 'fatal:.*'
    return 0
  else
    return 1
  endif
endfunction

function! FindCodeDirOrRoot()
  let filedir = expand('%:p:h')
  if isdirectory(filedir)
    if HasGitRepo(filedir)
      let cmd = 'bash -c ''(cd ' . filedir . ' ; git rev-parse --show-toplevel 2>/dev/null )'''
      let gitdir = system(cmd)
      if strlen(gitdir) == 0
        return '/'
      else
        return gitdir[:-2] " chomp
      endif
    else
      return '/'
    endif
  else
    return '/'
  endif
endfunction

function! GetThatBranch(root)
  if a:root != '/'
    if !has_key(g:last_known_branch, a:root)
      let g:last_known_branch[a:root] = ''
    endif
    return g:last_known_branch[a:root]
  else
    return ''
  endif
endfunction

function! UpdateThatBranch(root)
  if a:root != '/'
    let g:last_known_branch[a:root] = GetThisBranch(a:root)
  endif
endfunction

function! GetThisBranch(root)
  let file = a:root . '/.current_branch'
  if filereadable(file)
    return substitute(readfile(file)[0], '/', '-', 'g')
  elseif HasGitRepo(a:root)
    return substitute(fugitive#head(), '/', '-', 'g')
  else
    throw "You're not in a git repo"
  endif
endfunction

function! ListTagFiles(thisdir, thisbranch, isGit)
  let fs = split(glob($HOME . '/.vim-tags/*-tags'), "\n")
  let ret = []
  for f in fs
    let fprime = substitute(f, '^.*/' . a:thisdir, '', '')
    if a:isGit
      if match(f, '-' . a:thisbranch . '-') != -1
        call add(ret, f)
      endif
    elseif fprime !=# f
      call add(ret, f)
    endif
  endfor
  return ret
endfunction

function! MaybeRunBranchSwitch()
  let root = FindCodeDirOrRoot()
  let isGit = HasGitRepo(expand('%:p:h'))
  if root != "/"
    let thisbranch = GetThisBranch(root)
    let thatbranch = GetThatBranch(root)
    if thisbranch != ''
      let codedir = substitute(root, '/', '-', 'g')[1:]
      let fs = ListTagFiles(codedir, thisbranch, isGit)
      if len(fs) != 0
        execute 'setlocal tags=' . join(fs, ",")
      endif
      if thisbranch != thatbranch
        call UpdateThatBranch(root)
        "CtrlPClearCache
      endif
    endif
  endif
endfunction

function! MaybeRunMakeTags()
  let root = FindCodeDirOrRoot()
  if root != "/"
    call system("~/.vim/bin/maketags -c " . root . " &")
  endif
endfunction

augroup augroup_git
  au!
  au BufEnter * call MaybeRunBranchSwitch()
  au BufWritePost *.cs,*.js,*.java,*.conf,*.config call MaybeRunMakeTags()
augroup END

command! RunBranchSwitch call MaybeRunBranchSwitch()

function! LaunchForThisGitProject(cmd)
  let dirs = split(expand('%:p:h'), '/')
  let target = '/'
  while len(dirs) != 0
    let d = join(dirs, '/') "for Windows
    if isdirectory(d . '/.git')
      let target = d
      break
    else
      let dirs = dirs[:-2]
    endif
  endwhile
  if target == '/'
    echoerr "Project directory resolved to '/'"
  else
    execute ":" . a:cmd . " " . target
  endif
endfunction
"-----------------------------------------------------------------------------
" Functions
"-----------------------------------------------------------------------------
function! StripTrailingWhitespace()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  %s/\s\+$//e
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

function! BWipeoutAll()
  let lastbuf = bufnr('$')
  let ids = sort(filter(range(1, lastbuf), 'bufexists(v:val)'))
  execute ":" . ids[0] . "," . lastbuf . "bwipeout"
  unlet lastbuf
endfunction

if !exists('g:bufferJumpList')
  let g:bufferJumpList = {}
endif

function! IndentToNextBraceInLineAbove()
  :normal 0wk
  :normal "vyf(
  let @v = substitute(@v, '.', ' ', 'g')
  :normal j"vPl
endfunction

nmap <silent> ,ii :call IndentToNextBraceInLineAbove()<cr>

function! DiffCurrentFileAgainstAnother(snipoff, replacewith)
  let currentFile = expand('%:p')
  let otherfile = substitute(currentFile, "^" . a:snipoff, a:replacewith, '')
  only
  execute "vertical diffsplit " . otherfile
endfunction

command! -nargs=+ DiffCurrent call DiffCurrentFileAgainstAnother(<f-args>)

function! RunSystemCall(systemcall)
  let output = system(a:systemcall)
  let output = substitute(output, "\n", '', 'g')
  return output
endfunction

function! HighlightAllOfWord(onoff)
  if a:onoff == 1
    :augroup highlight_all
    :au!
    :au CursorMoved * silent! exe printf('match Search /\<%s\>/', expand('<cword>'))
    :augroup END
  else
    :au! highlight_all
    match none /\<%s\>/
  endif
endfunction

:nmap ,ha :call HighlightAllOfWord(1)<cr>
:nmap ,hA :call HighlightAllOfWord(0)<cr>

function! LengthenCWD()
  let cwd = getcwd()
  if cwd == '/'
    return
  endif
  let lengthend = substitute(cwd, '/[^/]*$', '', '')
  if lengthend == ''
    let lengthend = '/'
  endif
  if cwd != lengthend
    exec ":lcd " . lengthend
  endif
endfunction

:nmap ,ld :call LengthenCWD()<cr>

function! ShortenCWD()
  let cwd = split(getcwd(), '/')
  let filedir = split(expand("%:p:h"), '/')
  let i = 0
  let newdir = ""
  while i < len(filedir)
    let newdir = newdir . "/" . filedir[i]
    if len(cwd) == i || filedir[i] != cwd[i]
      break
    endif
    let i = i + 1
  endwhile
  " exec ":lcd /" . newdir
  exec ":lcd " . newdir
endfunction

:nmap ,nd :call ShortenCWD()<cr>

function! RedirToYankRegisterF(cmd, ...)
  let cmd = a:cmd . " " . join(a:000, " ")
  redir @*>
  exe cmd
  redir END
endfunction

command! -complete=command -nargs=+ RedirToYankRegister
      \ silent! call RedirToYankRegisterF(<f-args>)

"
"Format JSON
com! FormatJSON %!python -m json.tool
"
"Format XML
com! FormatXML :%!python -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
nnoremap = :FormatXML<Cr>

" -----------------------------------------------------------------------------
" Basic autocommands
" -----------------------------------------------------------------------------

" Reduce delay when switching between modes.
augroup NoInsertKeycodes
  autocmd!
  autocmd InsertEnter * set ttimeoutlen=0
  autocmd InsertLeave * set ttimeoutlen=50
augroup END

" Auto-resize splits when Vim gets resized.
autocmd VimResized * wincmd =

" Update a buffer's contents on focus if it changed outside of Vim.
au FocusGained,BufEnter * :checktime

" Unset paste on InsertLeave.
autocmd InsertLeave * silent! set nopaste

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set syntax=python

" Ensure tabs don't get converted to spaces in Makefiles.
autocmd FileType make setlocal noexpandtab

" ----------------------------------------------------------------------------
" Basic commands
" ----------------------------------------------------------------------------

" Add all TODO items to the quickfix list relative to where you opened Vim.
function! s:todo() abort
  let entries = []
  for cmd in ['git grep -niIw -e TODO -e FIXME 2> /dev/null',
            \ 'grep -rniIw -e TODO -e FIXME . 2> /dev/null']
    let lines = split(system(cmd), '\n')
    if v:shell_error != 0 | continue | endif
    for line in lines
      let [fname, lno, text] = matchlist(line, '^\([^:]*\):\([^:]*\):\(.*\)')[1:3]
      call add(entries, { 'filename': fname, 'lnum': lno, 'text': text })
    endfor
    break
  endfor

  if !empty(entries)
    call setqflist(entries)
    copen
  endif
endfunction

command! Todo call s:todo()

"-----------------------------------------------------------------------------
" Auto commands
"-----------------------------------------------------------------------------
augroup augroup_xsd
  au!
  au BufEnter *.json,*.xsd,*.wsdl,*.xml setl tabstop=4 shiftwidth=4
augroup END

augroup Binary
  au!
  au BufReadPre   *.bin let &bin=1
  au BufReadPost  *.bin if &bin | %!xxd
  au BufReadPost  *.bin set filetype=xxd | endif
  au BufWritePre  *.bin if &bin | %!xxd -r
  au BufWritePre  *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

" -----------------------------------------------------------------------------
" Plugin settings, mappings and autocommands
" -----------------------------------------------------------------------------

" .............................................................................
" junegunn/fzf.vim
" .............................................................................

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

" fzf {
" nnoremap <C-p> :<C-u>FZF<CR>
" }
" Launch fzf with CTRL+P.
nnoremap <silent> <C-p> :FZF -m<CR>

" Map a few common things to do with FZF.
nnoremap <silent> <Leader><Enter> :Buffers<CR>
nnoremap <silent> <Leader>l :Lines<CR>

" Allow passing optional flags into the Rg command.
"   Example: :Rg myterm -g '*.md'
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case " . <q-args>, 1, <bang>0)


" .............................................................................
" ntpeters/vim-better-whitespace
" .............................................................................

let g:strip_whitespace_confirm=0
let g:strip_whitespace_on_save=1

" .............................................................................
" Konfekt/FastFold
" .............................................................................

let g:fastfold_savehook=0
let g:fastfold_fold_command_suffixes=[]

" .............................................................................
" junegunn/limelight.vim
" .............................................................................

let g:limelight_conceal_ctermfg=244

" .............................................................................
" plasticboy/vim-markdown
" .............................................................................

autocmd FileType markdown let b:sleuth_automatic=0
autocmd FileType markdown set conceallevel=0
autocmd FileType markdown normal zR

let g:vim_markdown_frontmatter=1

" .............................................................................
" iamcco/markdown-preview.nvim
" .............................................................................

let g:mkdp_refresh_slow=1
let g:mkdp_markdown_css='/home/mikekim/.local/lib/github-markdown-css/github-markdown.css'

"-----------------------------------------------------------------------------
" Local system overrides
"-----------------------------------------------------------------------------
if filereadable($HOME . "/.vimrc.local")
  execute "source " . $HOME . "/.vimrc.local"
endif
