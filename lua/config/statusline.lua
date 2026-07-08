local M = {}

local modes = {
  n       = { "NORMAL",   "StNormal"  },
  i       = { "INSERT",   "StInsert"  },
  v       = { "VISUAL",   "StVisual"  },
  V       = { "V-LINE",   "StVisual"  },
  ["\22"] = { "V-BLOCK",  "StVisual"  },
  c       = { "COMMAND",  "StCommand" },
  R       = { "REPLACE",  "StReplace" },
  s       = { "SELECT",   "StVisual"  },
  S       = { "S-LINE",   "StVisual"  },
  t       = { "TERMINAL", "StTerm"    },
}

local function setup_hl()
  local hi = vim.api.nvim_set_hl
  local bg = "#1b1818"
  local panel = "#292424"
  local fg = "#e7dfdf"

  hi(0, "StNormal",     { fg = bg, bg = "#7272ca", bold = true })
  hi(0, "StInsert",     { fg = bg, bg = "#4b8b8b", bold = true })
  hi(0, "StVisual",     { fg = bg, bg = "#8464c4", bold = true })
  hi(0, "StCommand",    { fg = bg, bg = "#a06e3b", bold = true })
  hi(0, "StReplace",    { fg = bg, bg = "#ca4949", bold = true })
  hi(0, "StTerm",       { fg = bg, bg = "#5485b6", bold = true })
  hi(0, "StNormalAlert",{ fg = bg, bg = "#ca4949", bold = true })

  hi(0, "StNormalSep",  { fg = "#7272ca", bg = bg })
  hi(0, "StInsertSep",  { fg = "#4b8b8b", bg = bg })
  hi(0, "StVisualSep",  { fg = "#8464c4", bg = bg })
  hi(0, "StCommandSep", { fg = "#a06e3b", bg = bg })
  hi(0, "StReplaceSep", { fg = "#ca4949", bg = bg })
  hi(0, "StTermSep",    { fg = "#5485b6", bg = bg })
  hi(0, "StNormalAlertSep", { fg = "#ca4949", bg = bg })

  hi(0, "StFile",       { fg = fg, bg = bg })
  hi(0, "StModified",   { fg = "#a06e3b", bg = bg })
  hi(0, "StFill",       { fg = fg, bg = bg })
  hi(0, "StRightSep",   { fg = panel, bg = bg })
  hi(0, "StRight",      { fg = "#8a8585", bg = panel })
  hi(0, "StPos",        { fg = fg, bg = panel, bold = true })
end

function M.render()
  local mode = vim.fn.mode()
  local m = modes[mode] or { mode:upper(), "StNormal" }
  local label, hl = m[1], m[2]

  local modified = vim.bo.modified and "  " or ""
  local readonly  = (vim.bo.readonly or not vim.bo.modifiable) and " 󰌾 " or ""
  local ft = vim.bo.filetype ~= "" and (" " .. vim.bo.filetype .. " ") or " text "
  local ime_label = vim.g.current_ime_label or "--"
  local mode_hl = hl
  local mode_sep_hl = hl .. "Sep"

  if mode == "n" and ime_label ~= "EN" then
    mode_hl = "StNormalAlert"
    mode_sep_hl = "StNormalAlertSep"
  end

  -- LSP diagnostics
  local errors   = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local diag = ""
  if errors > 0   then diag = diag .. "%#DiagnosticError#  " .. errors .. " " end
  if warnings > 0 then diag = diag .. "%#DiagnosticWarn#  " .. warnings .. " " end

  local branch = vim.b.gitsigns_head or ""
  local branch_str = branch ~= "" and (" (" .. branch .. ")") or ""

  local fname = vim.fn.expand("%:t")
  local display = fname ~= ""
    and "%t"
    or (vim.fn.fnamemodify(vim.fn.getcwd(), ":~") .. "/[scratch]")

  return table.concat({
    "%#" .. mode_hl .. "#  " .. label .. " ",
    "%#" .. mode_sep_hl .. "#\xee\x82\xb0",  --
    "%#StFile#  " .. display .. branch_str,
    modified,
    readonly,
    "%#StFill#" .. diag .. "%=",
    "%#StRightSep#\xee\x82\xb2",       --
    "%#StRight#" .. ft,
    "%#StRightSep#\xee\x82\xb2",
    "%#StPos#  %l:%c ",
    "%#StRight#  %p%% ",
  })
end

setup_hl()

-- re-apply highlights after colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_hl,
})

return M
