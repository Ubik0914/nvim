return {
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPre",
    opts = {},
  },
  {
    "luochen1990/rainbow",
    event = "BufReadPre",
    config = function()
      vim.g.rainbow_active = 1
    end,
  },
  {
    "psliwka/vim-smoothie",
    event = "BufReadPre",
    enabled = true,
  },
  {
    "sphamba/smear-cursor.nvim",
    event = "BufEnter",
    opts = {
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      scroll_buffer_space = true,
      legacy_computing_symbols_support = false,
    },
  },
}
