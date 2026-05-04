return {
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text" },
    config = function()
      vim.g.bullets_pad_right = 0
      vim.g.bullets_outline_levels = {}
    end,
  },
  {
    "preservim/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1  -- 1 = 折り畳み無効
      vim.g.markdown_recommended_style = 0
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}
