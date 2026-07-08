local opt = vim.opt

vim.opt.exrc = false

vim.env.PATH = "/opt/homebrew/opt/mysql-client@8.0/bin:" .. vim.env.PATH

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
-- cursorcolumn はカーソル移動ごとに列全体を再描画し重いため無効化
opt.cursorcolumn = false
opt.undofile = true
opt.whichwrap:append("h,l")

opt.title = true
opt.titlestring = "%t"

-- colorscheme は lua/plugins/colorscheme.lua（lazy 読込後）で適用する

opt.showmode   = false
opt.laststatus = 2
opt.guicursor = table.concat({
  "n-v-c:block-Cursor/lCursor-blinkon0-blinkoff0-blinkwait0",
  "i-ci:ver25-Cursor/lCursor",
  "r-cr:hor20-Cursor/lCursor",
  "o:hor50-Cursor/lCursor",
}, ",")
local sl = require("config.statusline")
opt.statusline = "%{%v:lua.require('config.statusline').render()%}"
