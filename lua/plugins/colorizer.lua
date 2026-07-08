return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- 全バッファへの色解析は重いため、色指定が出る FT のみに限定
    filetypes = { "css", "scss", "sass", "less", "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "json", "yaml", "lua" },
    user_default_options = {
      RGB = true,
      RRGGBB = true,
      names = false,
      RRGGBBAA = true,
      AARRGGBB = false,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      mode = "background",
    },
  },
}
