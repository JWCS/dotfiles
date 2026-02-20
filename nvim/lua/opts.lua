-- ~/.dotfiles/nvim/lua/opts.lua
-- Translated from .vimrc.min

local opt = vim.opt

-- Files
opt.autoread    = true
opt.history     = 500
opt.encoding    = "utf8"
opt.fileformats = "unix,dos,mac"
opt.backup      = false
opt.writebackup = false
opt.swapfile    = false

-- Display
opt.termguicolors  = true
opt.background     = "dark"
opt.number         = true
opt.relativenumber = true
opt.scrolloff      = 7
opt.cmdheight      = 2
opt.hidden         = true
opt.showcmd        = true
opt.ruler          = true
opt.showmatch      = true
opt.matchtime      = 2
opt.wrap           = true
opt.linebreak      = true
opt.textwidth      = 500
opt.errorbells     = false
-- lazyredraw: comment out if you see visual glitches with telescope/etc
opt.lazyredraw     = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true
opt.magic      = true

-- Indentation
opt.tabstop     = 2
opt.softtabstop = 2
opt.shiftwidth  = 2
opt.smarttab    = true
opt.expandtab   = true
opt.autoindent  = true
opt.smartindent = true

-- Folding
opt.foldmethod = "syntax"
opt.foldlevel  = 2

-- Wild menu
opt.wildmenu   = true
opt.wildmode   = "longest:full,full"
opt.wildignore = "*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*"

-- Misc
opt.backspace = "eol,start,indent"
opt.whichwrap:append("<,>,h,l")

vim.cmd("colorscheme desert")
