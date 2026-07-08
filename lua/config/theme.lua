-- 配色テーマの単一の情報源。
-- 適用・永続化・切替コマンド・アクセント色の導出をここに集約し、
-- init.lua / colorscheme.lua / dashboard.lua など各所から参照する。
local M = {}

-- 起動時デフォルトと、適用失敗時のフォールバック（自作 colorscheme）
M.default = "base16-atelier-plateau"
M.fallback = "dark_modern"

-- :Theme の補完候補（実在するスキーム名）
M.themes = {
  "base16-atelier-plateau",
  "base16-atelier-plateau-light",
  "kanagawa",
  "kanagawa-wave",
  "kanagawa-dragon",
  "kanagawa-lotus",
  "dracula",
  "dracula-soft",
}

-- 選択したテーマを次回起動へ持ち越すための状態ファイル
local STATE = vim.fn.stdpath("data") .. "/last-theme"

-- 自動保存の一時抑制フラグ。起動時適用・フォールバック・ピッカープレビュー中は
-- ColorScheme autocmd による永続化を止め、意図しないテーマを保存しないようにする。
M._suppress_persist = false

-- atelier-plateau のパレット（どこからも色が取れないときの最終手段）
local FALLBACK = {
  base02 = "#585050", base08 = "#ca4949", base0A = "#a06e3b",
  base0C = "#5485b6", base0D = "#7272ca",
}

local function read_state()
  local ok, lines = pcall(vim.fn.readfile, STATE)
  if ok and lines and lines[1] and lines[1] ~= "" then return lines[1] end
  return nil
end

local function write_state(name)
  pcall(vim.fn.writefile, { name }, STATE)
end

-- base16 テーマがアクティブなら、その公式パレット(base00..base0F)を返す
local function base16_palette()
  local ok, m = pcall(require, "base16-colorscheme")
  if ok and m.colors and m.colors.base00 and (vim.g.colors_name or ""):match("^base16") then
    return m.colors
  end
  return nil
end

-- ハイライト群 group の attr("fg"/"bg") を "#rrggbb" で返す（無ければ nil）
local function hl_color(group, attr)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and h and h[attr] then return string.format("#%06x", h[attr]) end
  return nil
end

-- 2色間を t(0..1) で線形補間して "#rrggbb" を返す
function M.lerp_hex(a, b, t)
  local function rgb(h)
    return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  end
  local ar, ag, ab = rgb(a)
  local br, bg, bb = rgb(b)
  return string.format("#%02x%02x%02x",
    math.floor(ar + (br - ar) * t + 0.5),
    math.floor(ag + (bg - ag) * t + 0.5),
    math.floor(ab + (bb - ab) * t + 0.5))
end

-- alpha 等で使うアクセント色。アクティブなテーマに追従する。
-- base16 はパレットから、それ以外は標準ハイライト群から導出する。
function M.accents()
  local p = base16_palette()
  if p then
    return {
      grad_from = p.base0A, grad_to = p.base08,
      button = p.base0D, shortcut = p.base0C, selbg = p.base02,
    }
  end
  return {
    grad_from = hl_color("Type", "fg") or FALLBACK.base0A,
    grad_to   = hl_color("Constant", "fg") or FALLBACK.base08,
    button    = hl_color("Function", "fg") or FALLBACK.base0D,
    shortcut  = hl_color("Keyword", "fg") or hl_color("Statement", "fg") or FALLBACK.base0C,
    selbg     = hl_color("Visual", "bg") or hl_color("CursorLine", "bg") or FALLBACK.base02,
  }
end

-- テーマを適用する。persist=false のときは状態ファイルへ保存しない。
-- 失敗時はフォールバックへ退避し、起動をブロックしない。
function M.set(name, persist)
  if not pcall(vim.cmd.colorscheme, name) then
    pcall(vim.cmd.colorscheme, M.fallback)
    vim.schedule(function()
      vim.notify(
        ("theme: '%s' が見つからず %s にフォールバックしました"):format(tostring(name), M.fallback),
        vim.log.levels.WARN)
    end)
    return false
  end
  if persist ~= false then write_state(name) end
  return true
end

-- 起動時適用：前回選択(あれば) → デフォルト の順。適用のみで永続化はしない。
function M.apply()
  M._suppress_persist = true
  M.set(read_state() or M.default, false)
  M._suppress_persist = false
end

-- プレビューペインに表示するサンプルコード（各テーマの主要ハイライトが見えるよう配慮）
local PREVIEW_SAMPLE = {
  "-- theme preview",
  "local M = {}",
  "",
  'local NAME  = "nvim"   -- string',
  "local count = 42       -- number",
  "",
  "--- Greet a user by name.",
  "function M.greet(name)",
  "  if name == nil then",
  "    return false",
  "  end",
  '  print("hello, " .. name)  -- call',
  "  return true",
  "end",
  "",
  "-- @todo: wire up config",
  "return M",
}

-- テーマ選択 UI。左に一覧・右にサンプルコードのプレビューを並べた浮動ウィンドウ。
-- j/k で移動するとカーソル位置のテーマを即適用（右ペインに反映）、Enter で確定＆永続化、
-- Esc/q で元のテーマに戻して閉じる。
function M.pick()
  local themes = M.themes
  local original = vim.g.colors_name
  local original_bg = vim.o.background

  -- プレビュー中の colorscheme 切替は保存しない（確定時のみ M.set が永続化する）
  M._suppress_persist = true

  local list_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, themes)
  vim.bo[list_buf].modifiable = false

  local prev_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(prev_buf, 0, -1, false, PREVIEW_SAMPLE)
  vim.bo[prev_buf].filetype = "lua" -- treesitter/syntax でハイライトさせる
  vim.bo[prev_buf].modifiable = false

  local list_w = 30
  local prev_w = math.min(52, vim.o.columns - list_w - 8)
  local height = math.min(math.max(#themes, #PREVIEW_SAMPLE), vim.o.lines - 6)
  local total_w = list_w + prev_w + 3
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - total_w) / 2)

  local prev_win = vim.api.nvim_open_win(prev_buf, false, {
    relative = "editor", width = prev_w, height = height,
    row = row, col = col + list_w + 3, style = "minimal",
    border = "rounded", title = " Preview ", title_pos = "center", focusable = false,
  })
  local list_win = vim.api.nvim_open_win(list_buf, true, {
    relative = "editor", width = list_w, height = height,
    row = row, col = col, style = "minimal",
    border = "rounded", title = " Theme (j/k · ⏎ · Esc) ", title_pos = "center",
  })
  vim.wo[list_win].cursorline = true

  -- 現在のテーマがあれば、その行から開始
  local start = 1
  for i, n in ipairs(themes) do
    if n == original then start = i break end
  end
  vim.api.nvim_win_set_cursor(list_win, { start, 0 })

  local closed = false
  local function close(restore)
    if closed then return end
    closed = true
    if restore and original then
      pcall(vim.cmd.colorscheme, original)
      vim.o.background = original_bg
    end
    pcall(vim.api.nvim_win_close, prev_win, true)
    pcall(vim.api.nvim_win_close, list_win, true)
    M._suppress_persist = false -- 復元の colorscheme を保存し終えてから解除
  end

  local grp = vim.api.nvim_create_augroup("ThemePickerPreview", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = grp, buffer = list_buf,
    callback = function()
      pcall(vim.cmd.colorscheme, themes[vim.api.nvim_win_get_cursor(list_win)[1]])
    end,
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = grp, buffer = list_buf, once = true,
    callback = function() close(true) end, -- 予期せず離脱したら元に戻す（closed ガードで確定時は無効）
  })
  pcall(vim.cmd.colorscheme, themes[start]) -- 初期プレビュー

  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = list_buf, nowait = true, silent = true })
  end
  map("<CR>", function()
    local name = themes[vim.api.nvim_win_get_cursor(list_win)[1]]
    close(false) -- 選択テーマを適用したまま閉じる
    M.set(name)  -- 永続化（＆再適用）
  end)
  map("<Esc>", function() close(true) end)
  map("q", function() close(true) end)
end

-- :Theme <name>（Tab 補完付き）を定義する
function M.setup_command()
  -- 素の :colorscheme での変更も次回起動へ持ち越す。
  -- 起動時適用・フォールバック・ピッカープレビューは _suppress_persist で除外する。
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ThemePersist", { clear = true }),
    callback = function(ev)
      if M._suppress_persist then return end
      if ev.match and ev.match ~= "" then write_state(ev.match) end
    end,
  })

  vim.api.nvim_create_user_command("Theme", function(opts)
    M.set(opts.args)
  end, {
    nargs = 1,
    complete = function(arglead)
      return vim.tbl_filter(function(t)
        return t:find(arglead, 1, true) == 1
      end, M.themes)
    end,
  })
end

return M
