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
    commit = "a923f5fc5ba36a3b17e289dc35dc17f66d0548ee",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    build = function()
      -- Node.js バイナリを外部からダウンロードする。commit ピンで変更検知する
      vim.fn["mkdp#util#install"]()
    end,
  },
}
