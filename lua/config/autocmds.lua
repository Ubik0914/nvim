local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.filetype.add({
  pattern = {
    [".*/ghostty/config"] = "ghostty",
    [".*ghostty/config%.ghostty"] = "ghostty",
  },
})

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "ghostty",
  callback = function()
    vim.bo.commentstring = "# %s"
  end,
})

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

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

local function force_abc_input()
  local im_select = "/opt/homebrew/bin/im-select"
  if vim.fn.executable(im_select) == 1 then
    vim.fn.jobstart({ im_select, "com.apple.keylayout.ABC" }, { detach = true })
  end
end

local ime_label_map = {
  ["com.apple.keylayout.ABC"] = "EN",
  ["com.apple.keylayout.US"] = "EN",
  ["com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"] = "JP",
  ["com.apple.inputmethod.Kotoeri.Japanese"] = "JP",
}

-- im-select の呼び出しは ~40-50ms/回。同期(systemlist)だと UI をブロックするため
-- jobstart で非同期化する。多重起動は job_running で抑止。
local ime_job_running = false
local function refresh_ime_status()
  local im_select = "/opt/homebrew/bin/im-select"
  if vim.fn.executable(im_select) ~= 1 then
    vim.g.current_ime_label = "--"
    vim.cmd("redrawstatus")
    return
  end
  if ime_job_running then
    return
  end
  ime_job_running = true

  local output = {}
  vim.fn.jobstart({ im_select }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            output[#output + 1] = line
          end
        end
      end
    end,
    on_exit = function()
      ime_job_running = false
      local source = output[1] or ""
      vim.g.current_ime_label = ime_label_map[source] or source
      vim.schedule(function()
        vim.cmd("redrawstatus")
      end)
    end,
  })
end

vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  pattern = "*",
  callback = function()
    local mode = vim.fn.mode()
    if mode == "n" or mode == "v" or mode == "V" or mode == "\22" then
      force_abc_input()
    end
    vim.defer_fn(refresh_ime_status, 80)
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = group,
  callback = function()
    force_abc_input()
    vim.defer_fn(refresh_ime_status, 80)
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "FocusGained", "VimEnter" }, {
  group = group,
  callback = function()
    vim.defer_fn(refresh_ime_status, 80)
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    set_transparent_background()
  end,
})

vim.keymap.set("c", "<CR>", function()
  if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "q" then
    return "<C-u>Alpha<CR>"
  end
  return "<CR>"
end, { expr = true, silent = false })
