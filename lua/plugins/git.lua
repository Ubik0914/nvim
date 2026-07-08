return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▁" },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- ハンク間移動
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")

        -- ハンクのステージ・リセット
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

        -- 差分プレビュー
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

        -- 行blame
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>dv", "<cmd>DiffviewOpen<cr>",              desc = "Diffview open" },
      { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>",     desc = "Diffview file history" },
      { "<leader>dH", "<cmd>DiffviewFileHistory<cr>",       desc = "Diffview repo history" },
      { "<leader>dc", "<cmd>DiffviewClose<cr>",             desc = "Diffview close" },
    },
  },
}
