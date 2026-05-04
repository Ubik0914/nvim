return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter",
    opts = {
      ensure_installed = { "php", "lua", "javascript", "typescript", "html", "css", "json", "bash", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
