vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

require("config.options")
require("config.keymaps")
require("config.autocmds")

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- 全カラースキームプラグイン読込後に、テーマを一元適用＆:Theme を定義
require("config.theme").setup_command()
require("config.theme").apply()
