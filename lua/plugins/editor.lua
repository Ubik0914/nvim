return {
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPre",
    opts = {},
  },
  -- rainbow(旧式・正規表現ベース)は大きいファイルで低速なため無効化
  {
    "luochen1990/rainbow",
    enabled = false,
    event = "BufReadPre",
    config = function()
      vim.g.rainbow_active = 1
    end,
  },
  -- スクロール/カーソルのアニメは移動を重く見せるため無効化（体感優先）
  {
    "psliwka/vim-smoothie",
    enabled = false,
  },
  {
    "sphamba/smear-cursor.nvim",
    enabled = false,
    event = "BufEnter",
    opts = {},
  },
}
