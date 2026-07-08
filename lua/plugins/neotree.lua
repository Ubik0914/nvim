return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
      { "<D-S-d>", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
      { "\x1b[68;10u", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree (Cmd+Shift+D via Ghostty)" },
    },
    opts = {
      close_if_last_window = true,
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
      },
    },
  },
}
