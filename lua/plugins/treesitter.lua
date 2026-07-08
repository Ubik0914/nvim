return {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "cf12346a3414fa1b06af75c79faebe7f76df080a",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter",
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      -- ghostty パーサーは個人リポジトリの C ソースをコンパイルするため除去
      ensure_installed = { "php", "lua", "javascript", "typescript", "html", "css", "json", "bash", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
