local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "php",
  callback = function()
    vim.cmd([[syn match phpImportPath /\(^\s*use\s\+\)\@<=[A-Za-z0-9_\\]\+/ containedin=phpRegion]])
  end,
})

local function set_transparent_background()
  local transparent_groups = {
    "Normal",
    "NormalFloat",
    "SignColumn",
    "LineNr",
    "CursorLineNr",
    "EndOfBuffer",
    "FoldColumn",
    "StatusLine",
    "StatusLineNC",
    "VertSplit",
  }

  for _, name in ipairs(transparent_groups) do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    hl.bg = nil
    hl.ctermbg = nil
    vim.api.nvim_set_hl(0, name, hl)
  end
end

set_transparent_background()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_transparent_background,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Force ABC input method when entering normal/visual mode (not during search)
vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  pattern = { "*:n", "*:v", "*:V", "*:\22" },
  callback = function()
    vim.fn.jobstart({ "im-select", "com.apple.keylayout.ABC" })
  end,
})
