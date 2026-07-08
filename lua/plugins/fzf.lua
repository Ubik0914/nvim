return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({})

    local function git_branch_title()
      local dir = vim.fn.expand("%:p:h")
      if dir == "" then dir = vim.fn.getcwd() end
      local c = "-C " .. vim.fn.shellescape(dir) .. " "

      local branch = vim.trim(vim.fn.system("git " .. c .. "branch --show-current 2>/dev/null"))
      if vim.v.shell_error ~= 0 then return nil end
      if branch == "" then
        branch = vim.trim(vim.fn.system("git " .. c .. "rev-parse --short HEAD 2>/dev/null"))
        if vim.v.shell_error ~= 0 or branch == "" then return nil end
      end

      local upstream = vim.trim(vim.fn.system("git " .. c .. "rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null"))
      if vim.v.shell_error ~= 0 or upstream == "" then
        return " " .. branch .. " "
      end
      return " " .. branch .. "  →  " .. upstream .. " "
    end

    local function with_branch(picker)
      return function()
        local title = git_branch_title()
        require("fzf-lua")[picker](title and { winopts = { title = title } } or {})
      end
    end

    vim.keymap.set("n", "<D-p>",      "<cmd>FzfLua files<cr>",     { silent = true })
    vim.keymap.set("n", "<D-S-f>",    "<cmd>FzfLua live_grep<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gs", with_branch("git_status"),   { silent = true, desc = "Git status" })
    vim.keymap.set("n", "<leader>gb", with_branch("git_branches"), { silent = true, desc = "Git branches" })
    vim.keymap.set("n", "<leader>gl", with_branch("git_commits"),  { silent = true, desc = "Git log" })
  end,
}
