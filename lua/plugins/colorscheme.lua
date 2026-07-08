-- カラースキーム本体（3系統）。適用は lua/config/theme.lua に一元化するため、
-- ここでは登録のみ（config で colorscheme を呼ばない＝適用の取り合いを防ぐ）。
-- いずれも起動時ロードして :Theme で即時切替できるようにする。
return {
  { "RRethy/nvim-base16", lazy = false, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  { "Mofiqul/dracula.nvim", name = "dracula", lazy = false, priority = 1000 },
}
