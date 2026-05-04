vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.g.colors_name = "dark_modern"
vim.opt.background = "dark"

local hi = vim.api.nvim_set_hl

-- Palette (VS Code Dark Modern)
local c = {
  bg        = "#1F1F1F",
  bg_dark   = "#181818",
  bg_sel    = "#3A3D41",
  fg        = "#CCCCCC",
  fg_dim    = "#9D9D9D",
  lnum      = "#6E7681",
  comment   = "#6A9955",
  string    = "#CE9178",
  number    = "#B5CEA8",
  keyword   = "#569CD6",
  ctrl      = "#C586C0",
  func      = "#DCDCAA",
  type      = "#4EC9B0",
  variable  = "#9CDCFE",
  constant  = "#4FC1FF",
  operator  = "#D4D4D4",
  css_prop  = "#D7BA7D",
  regex     = "#D16969",
  error     = "#F44747",
  accent    = "#0078D4",
  search_bg = "#9E6A03",
}

-- Editor base
hi(0, "Normal",          { fg = c.fg,      bg = c.bg })
hi(0, "NormalFloat",     { fg = c.fg,      bg = "#202020" })
hi(0, "EndOfBuffer",     { fg = c.bg })
hi(0, "LineNr",          { fg = c.lnum })
hi(0, "CursorLineNr",    { fg = c.fg })
hi(0, "CursorLine",      { bg = "#2A2A2A" })
hi(0, "SignColumn",      { bg = c.bg })
hi(0, "ColorColumn",     { bg = "#2A2A2A" })
hi(0, "Visual",          { bg = c.bg_sel })
hi(0, "Search",          { fg = "#FFFFFF", bg = c.search_bg })
hi(0, "IncSearch",       { fg = "#FFFFFF", bg = c.search_bg })
hi(0, "CurSearch",       { fg = "#FFFFFF", bg = c.search_bg })
hi(0, "MatchParen",      { fg = c.keyword, bold = true })
hi(0, "NonText",         { fg = c.lnum })
hi(0, "SpecialKey",      { fg = c.lnum })
hi(0, "Folded",          { fg = c.fg_dim,  bg = "#2B2B2B" })
hi(0, "FoldColumn",      { fg = c.lnum,    bg = c.bg })
hi(0, "Conceal",         { fg = c.fg_dim })
hi(0, "Directory",       { fg = c.keyword })
hi(0, "Title",           { fg = c.keyword, bold = true })

-- Statusline / Tabline
hi(0, "StatusLine",      { fg = c.fg,     bg = c.bg_dark })
hi(0, "StatusLineNC",    { fg = c.fg_dim, bg = c.bg_dark })
hi(0, "TabLine",         { fg = c.fg_dim, bg = c.bg_dark })
hi(0, "TabLineSel",      { fg = c.fg,     bg = c.bg })
hi(0, "TabLineFill",     { bg = c.bg_dark })

-- Popup menu
hi(0, "Pmenu",           { fg = c.fg,     bg = "#252526" })
hi(0, "PmenuSel",        { fg = "#FFFFFF", bg = c.accent })
hi(0, "PmenuSbar",       { bg = "#3C3C3C" })
hi(0, "PmenuThumb",      { bg = "#616161" })

-- Messages
hi(0, "ErrorMsg",        { fg = c.error })
hi(0, "WarningMsg",      { fg = c.css_prop })
hi(0, "ModeMsg",         { fg = c.fg })
hi(0, "MoreMsg",         { fg = c.type })

-- Diff
hi(0, "DiffAdd",         { bg = "#1a3a2a" })
hi(0, "DiffChange",      { bg = "#1a2a3a" })
hi(0, "DiffDelete",      { bg = "#3a1a1a" })
hi(0, "DiffText",        { bg = "#1a2a4a" })

-- Git signs
hi(0, "GitSignsAdd",     { fg = "#2EA043" })
hi(0, "GitSignsChange",  { fg = c.accent })
hi(0, "GitSignsDelete",  { fg = "#F85149" })

-- ─── Syntax ──────────────────────────────────────────────

hi(0, "Comment",         { fg = c.comment, italic = true })
hi(0, "String",          { fg = c.string })
hi(0, "Character",       { fg = c.string })
hi(0, "Number",          { fg = c.number })
hi(0, "Float",           { fg = c.number })
hi(0, "Boolean",         { fg = c.keyword })
hi(0, "Constant",        { fg = c.constant })
hi(0, "Identifier",      { fg = c.variable })
hi(0, "Function",        { fg = c.func })
hi(0, "Statement",       { fg = c.keyword })
hi(0, "Keyword",         { fg = c.keyword })
hi(0, "Conditional",     { fg = c.ctrl })
hi(0, "Repeat",          { fg = c.ctrl })
hi(0, "Label",           { fg = c.ctrl })
hi(0, "Operator",        { fg = c.operator })
hi(0, "Exception",       { fg = c.ctrl })
hi(0, "PreProc",         { fg = c.keyword })
hi(0, "Include",         { fg = c.keyword })
hi(0, "Define",          { fg = c.keyword })
hi(0, "Macro",           { fg = c.keyword })
hi(0, "Type",            { fg = c.type })
hi(0, "StorageClass",    { fg = c.keyword })
hi(0, "Structure",       { fg = c.type })
hi(0, "Typedef",         { fg = c.type })
hi(0, "Special",         { fg = c.css_prop })
hi(0, "SpecialChar",     { fg = c.css_prop })
hi(0, "Tag",             { fg = c.keyword })
hi(0, "Delimiter",       { fg = c.operator })
hi(0, "SpecialComment",  { fg = c.comment })
hi(0, "Debug",           { fg = c.error })
hi(0, "Underlined",      { underline = true })
hi(0, "Error",           { fg = c.error })
hi(0, "Todo",            { fg = c.func, bold = true })

-- ─── Treesitter ──────────────────────────────────────────

hi(0, "@comment",              { link = "Comment" })
hi(0, "@string",               { link = "String" })
hi(0, "@string.escape",        { fg = c.css_prop })
hi(0, "@string.regexp",        { fg = c.regex })
hi(0, "@number",               { link = "Number" })
hi(0, "@number.float",         { link = "Float" })
hi(0, "@boolean",              { link = "Boolean" })
hi(0, "@constant",             { fg = c.constant })
hi(0, "@constant.builtin",     { fg = c.keyword })
hi(0, "@variable",             { fg = c.variable })
hi(0, "@variable.builtin",     { fg = c.keyword })
hi(0, "@variable.parameter",   { fg = c.variable })
hi(0, "@variable.member",      { fg = c.variable })
hi(0, "@function",             { fg = c.func })
hi(0, "@function.builtin",     { fg = c.func })
hi(0, "@function.method",      { fg = c.func })
hi(0, "@function.call",        { fg = c.func })
hi(0, "@function.method.call", { fg = c.func })
hi(0, "@constructor",          { fg = c.type })
hi(0, "@keyword",              { fg = c.keyword })
hi(0, "@keyword.import",       { fg = c.keyword })
hi(0, "@keyword.return",       { fg = c.ctrl })
hi(0, "@keyword.exception",    { fg = c.ctrl })
hi(0, "@keyword.conditional",  { fg = c.ctrl })
hi(0, "@keyword.repeat",       { fg = c.ctrl })
hi(0, "@keyword.operator",     { fg = c.keyword })
hi(0, "@keyword.type",         { fg = c.keyword })
hi(0, "@type",                 { fg = c.type })
hi(0, "@type.builtin",         { fg = c.type })
hi(0, "@type.definition",      { fg = c.type })
hi(0, "@operator",             { fg = c.operator })
hi(0, "@punctuation",          { fg = c.operator })
hi(0, "@punctuation.bracket",  { fg = c.operator })
hi(0, "@punctuation.delimiter",{ fg = c.operator })
hi(0, "@tag",                  { fg = c.keyword })
hi(0, "@tag.attribute",        { fg = c.variable })
hi(0, "@tag.delimiter",        { fg = "#808080" })
hi(0, "@attribute",            { fg = c.css_prop })
hi(0, "@namespace",            { fg = c.type })
hi(0, "phpImportPath",         { fg = c.number })
hi(0, "@label",                { fg = "#C8C8C8" })
hi(0, "@property",             { fg = c.variable })

-- ─── LSP ─────────────────────────────────────────────────

hi(0, "DiagnosticError",            { fg = c.error })
hi(0, "DiagnosticWarn",             { fg = c.css_prop })
hi(0, "DiagnosticInfo",             { fg = c.keyword })
hi(0, "DiagnosticHint",             { fg = c.type })
hi(0, "DiagnosticUnderlineError",   { undercurl = true, sp = c.error })
hi(0, "DiagnosticUnderlineWarn",    { undercurl = true, sp = c.css_prop })
hi(0, "DiagnosticUnderlineInfo",    { undercurl = true, sp = c.keyword })
hi(0, "DiagnosticUnderlineHint",    { undercurl = true, sp = c.type })
hi(0, "LspReferenceText",           { bg = c.bg_sel })
hi(0, "LspReferenceRead",           { bg = c.bg_sel })
hi(0, "LspReferenceWrite",          { bg = c.bg_sel })
