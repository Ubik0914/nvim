return {
  {
    "williamboman/mason.nvim",
    commit = "e54f5bf5f12c560da31c17eee5b3e1bd369f3ff9",
    build = ":MasonUpdate",
    -- 単体呼び出し用。実体はファイルを開いた時に lspconfig 経由でロードされる
    cmd = { "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonLog" },
    opts = {
      -- レジストリを明示。セキュリティ強化時は @<tag> でバージョン固定する
      -- 例: "github:mason-org/mason-registry@2024-11-28-manic-mantis"
      registries = {
        "github:mason-org/mason-registry",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "ts_ls",
        "intelephense",
        "pyright",
        "bashls",
        "lua_ls",
      },
      automatic_enable = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    -- ファイルを開いた時に mason チェーンごと遅延ロード（起動時ロードを回避）
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    end,
  },
}
