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
  local bg = "#1F1F1F"

  hi(0, "StNormal",     { fg = "#1F1F1F", bg = "#569CD6", bold = true })
  hi(0, "StInsert",     { fg = "#1F1F1F", bg = "#4EC9B0", bold = true })
  hi(0, "StVisual",     { fg = "#1F1F1F", bg = "#C586C0", bold = true })
  hi(0, "StCommand",    { fg = "#1F1F1F", bg = "#DCDCAA", bold = true })
  hi(0, "StReplace",    { fg = "#1F1F1F", bg = "#F44747", bold = true })
  hi(0, "StTerm",       { fg = "#1F1F1F", bg = "#4EC9B0", bold = true })

  hi(0, "StNormalSep",  { fg = "#569CD6", bg = bg })
  hi(0, "StInsertSep",  { fg = "#4EC9B0", bg = bg })
  hi(0, "StVisualSep",  { fg = "#C586C0", bg = bg })
  hi(0, "StCommandSep", { fg = "#DCDCAA", bg = bg })
  hi(0, "StReplaceSep", { fg = "#F44747", bg = bg })
  hi(0, "StTermSep",    { fg = "#4EC9B0", bg = bg })

  hi(0, "StFile",       { fg = "#CCCCCC", bg = bg })
  hi(0, "StModified",   { fg = "#DCDCAA", bg = bg })
  hi(0, "StFill",       { fg = "#CCCCCC", bg = bg })
  hi(0, "StRightSep",   { fg = "#2B2B2B", bg = bg })
  hi(0, "StRight",      { fg = "#9D9D9D", bg = "#2B2B2B" })
  hi(0, "StPos",        { fg = "#CCCCCC", bg = "#2B2B2B", bold = true })
end

function M.render()
  local mode = vim.fn.mode()
  local m = modes[mode] or { mode:upper(), "StNormal" }
  local label, hl = m[1], m[2]

  local modified = vim.bo.modified and "  " or ""
  local readonly  = (vim.bo.readonly or not vim.bo.modifiable) and " 󰌾 " or ""
  local ft = vim.bo.filetype ~= "" and (" " .. vim.bo.filetype .. " ") or " text "

  -- LSP diagnostics
  local errors   = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local diag = ""
  if errors > 0   then diag = diag .. "%#DiagnosticError#  " .. errors .. " " end
  if warnings > 0 then diag = diag .. "%#DiagnosticWarn#  " .. warnings .. " " end

  return table.concat({
    "%#" .. hl .. "#  " .. label .. " ",
    "%#" .. hl .. "Sep#\xee\x82\xb0",  --
    "%#StFile#  %t",
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
