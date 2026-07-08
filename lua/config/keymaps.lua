local keymap = vim.keymap.set
local opts = { silent = true }
local expr_opts = { silent = true, expr = true }

local function force_abc_input()
  local im_select = "/opt/homebrew/bin/im-select"
  if vim.fn.executable(im_select) == 1 then
    vim.fn.jobstart({ im_select, "com.apple.keylayout.ABC" }, { detach = true })
    vim.g.current_ime_label = "EN"
    vim.cmd("redrawstatus")
  end
end

local function swallow_japanese_input()
  force_abc_input()
  return ""
end

keymap("n", "<leader>w", "<cmd>write<cr>", opts)
keymap("n", "<leader>q", "<cmd>quit<cr>", opts)
keymap("n", "<leader>Q", "<cmd>quit!<cr>", opts)
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<leader>sv", "<C-w>v", opts)
keymap("n", "<leader>sh", "<C-w>s", opts)
keymap("n", "<D-CR>", "<C-w>v", opts)
keymap("n", "<D-S-CR>", "<C-w>s", opts)

keymap("n", "：", function()
  force_abc_input()
  return ":"
end, expr_opts)

for _, ch in ipairs(vim.fn.split(
  "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞた" ..
  "だちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽま" ..
  "みむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖゝゞ" ..
  "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタ" ..
  "ダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマ" ..
  "ミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヽヾ" ..
  "ー、。，．・：；？！゛゜「」『』［］（）｛｝〈〉《》【】" ..
  "〜～＿＋＝￥＄％＆＊＠＃’”｀｜／＼",
  "\\zs"
)) do
  keymap("n", ch, swallow_japanese_input, expr_opts)
end

-- Keep undo on u and map Cmd+Shift+U to redo when the terminal forwards it
keymap("n", "<D-S-u>", "<C-r>", opts)

vim.api.nvim_create_user_command("Cppath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.system("echo -n " .. vim.fn.shellescape(path) .. " | pbcopy")
  vim.notify(path)
end, {})

-- Format
keymap("n", "<leader>fs", ":%!sql-formatter<CR>", opts)
keymap("n", "<leader>fj", ":%!jq .<CR>", opts)
keymap("n", "<leader>fp", ":%!prettier --stdin-filepath %<CR>", opts)
keymap("n", "<leader>fy", ":%!black -q -<CR>", opts)
keymap("n", "<leader>fh", ":%!php-cs-fixer fix --using-cache=no -<CR>", opts)

-- Comment toggle (Cmd+/)
keymap("n", "<D-/>", function() require("Comment.api").toggle.linewise.current() end, opts)
keymap("v", "<D-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)

keymap("i", "jj", "<Esc><cmd>write<cr>", opts)

-- Insert mode cursor movement (Opt+hjkl)
keymap("i", "<M-h>", "<Left>",  opts)
keymap("i", "<M-j>", "<Down>",  opts)
keymap("i", "<M-k>", "<Up>",    opts)
keymap("i", "<M-l>", "<Right>", opts)

-- Emacs-style navigation
keymap({ "n", "v" }, "<M-a>", "^", opts)
keymap({ "n", "v" }, "<M-e>", "$", opts)
keymap("i", "<M-a>", "<C-o>^", opts)
keymap("i", "<M-e>", "<End>", opts)
keymap({ "n", "v" }, "<M-<>", "gg", opts)
keymap({ "n", "v" }, "<M->>", "G", opts)

vim.cmd("cnoreabbrev qq q!")
