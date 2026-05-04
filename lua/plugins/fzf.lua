return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({})
    vim.keymap.set("n", "<D-p>", "<cmd>FzfLua files<cr>",      { silent = true })
    vim.keymap.set("n", "<D-S-f>", "<cmd>FzfLua live_grep<cr>", { silent = true })
  end,
}
