local keymap = vim.keymap.set
local opts = { silent = true }

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

-- Keep undo on u and map Cmd+Shift+U to redo when the terminal forwards it
keymap("n", "<D-S-u>", "<C-r>", opts)

-- Format
keymap("n", "<leader>fs", ":%!sql-formatter<CR>", opts)
keymap("n", "<leader>fj", ":%!jq .<CR>", opts)
keymap("n", "<leader>fp", ":%!prettier --stdin-filepath %<CR>", opts)
keymap("n", "<leader>fy", ":%!black -q -<CR>", opts)
keymap("n", "<leader>fh", ":%!php-cs-fixer fix --using-cache=no -<CR>", opts)

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
