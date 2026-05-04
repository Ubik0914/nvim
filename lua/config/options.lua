local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitbelow = true
opt.splitright = true
opt.cursorline = true
opt.undofile = true

opt.title = true
opt.titlestring = "%t"

vim.cmd("colorscheme dark_modern")

opt.showmode   = false
opt.laststatus = 2
local sl = require("config.statusline")
opt.statusline = "%{%v:lua.require('config.statusline').render()%}"
