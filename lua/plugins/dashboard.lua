-- marquee scroll state (module-level so timer persists)
local _marquee = { timer = nil, items = {}, buf = nil }

-- 配色は lua/config/theme.lua に集約（palette / lerp_hex を共有）
local theme = require("config.theme")

local function stop_marquee()
  if _marquee.timer then
    _marquee.timer:stop()
    _marquee.timer:close()
    _marquee.timer = nil
  end
  _marquee.items = {}
end

local function start_marquee(buf)
  stop_marquee()
  _marquee.buf = buf

  local max_w = vim.o.columns - 4
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  for i, line in ipairs(lines) do
    if line:match("^%s+#%d+") and vim.fn.strdisplaywidth(line) > max_w then
      table.insert(_marquee.items, {
        lnum   = i - 1,
        full   = line,
        offset = 0,
        max_w  = max_w,
      })
    end
  end

  if #_marquee.items == 0 then return end

  _marquee.timer = vim.uv.new_timer()
  _marquee.timer:start(1500, 120, vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      stop_marquee()
      return
    end
    local ok = pcall(function()
      vim.bo[buf].modifiable = true
      for _, s in ipairs(_marquee.items) do
        local loop = s.full .. "    "
        local len  = #loop
        s.offset   = s.offset % len
        -- build display string of width max_w (byte-safe for ASCII PR titles)
        local src  = loop .. loop
        local disp = vim.fn.strcharpart(src, s.offset, s.max_w)
        -- pad to fixed width
        local pad  = s.max_w - vim.fn.strdisplaywidth(disp)
        if pad > 0 then disp = disp .. string.rep(" ", pad) end
        vim.api.nvim_buf_set_lines(buf, s.lnum, s.lnum + 1, false, { disp })
        s.offset = s.offset + 1
      end
      vim.bo[buf].modifiable = false
    end)
    if not ok then stop_marquee() end
  end))
end

local function get_claude_usage_lines()
  local usage_path = vim.fn.expand("~/.claude/usage-reset/last-usage-output.txt")
  local raw_lines = {}
  local function is_usage_output(lines)
    local text = table.concat(lines, "\n")
    return text:match("Current session:") ~= nil and text:match("resets ") ~= nil
  end

  if vim.fn.filereadable(usage_path) == 1 then
    raw_lines = vim.fn.readfile(usage_path)
    if not is_usage_output(raw_lines) then
      raw_lines = {}
    end
  end

  if #raw_lines == 0 and vim.fn.executable("claude") == 1 then
    raw_lines = vim.fn.systemlist("claude --print '/usage' 2>/dev/null")
  end

  if vim.v.shell_error ~= 0 or #raw_lines == 0 or not is_usage_output(raw_lines) then
    return {}
  end

  local text = table.concat(raw_lines, "\n")
  local formatted = {}

  local function add(line)
    if line and line ~= "" then
      table.insert(formatted, line)
    end
  end

  local function meter(label, percent)
    local width = 18
    local filled = math.floor((percent / 100) * width + 0.5)
    filled = math.max(0, math.min(width, filled))
    local empty = width - filled
    return string.format(
      "%-7s [%s%s] %3d%%",
      label,
      string.rep("▰", filled),
      string.rep("▱", empty),
      percent
    )
  end

  for _, item in ipairs({
    { label = "Current session", icon = "Session" },
    { label = "Current week %(all models%)", icon = "Weekly" },
    { label = "Current week %(Fable%)", icon = "Fable" },
  }) do
    local used, reset = text:match(item.label .. ":%s+([^·\n]+)·%s+resets%s+([^\n]+)")
    local percent = used and used:match("(%d+)%%")
    if used and reset and percent then
      add(meter(item.icon, tonumber(percent)))
      add(string.format("        reset %s", vim.trim(reset)))
      add(" ")
    end
  end

  if #formatted == 0 then
    return {}
  end

  if formatted[#formatted] == "" then
    table.remove(formatted, #formatted)
  end

  local max_w = math.max(20, vim.o.columns - 12)
  for i, line in ipairs(formatted) do
    formatted[i] = vim.fn.strcharpart(line, 0, max_w)
  end

  local width = 0
  for _, line in ipairs(formatted) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  for i, line in ipairs(formatted) do
    local pad = width - vim.fn.strdisplaywidth(line)
    if pad > 0 then
      formatted[i] = line .. string.rep(" ", pad)
    end
  end
  return formatted
end

return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                                       ▌       ▐    ",
        "                                                                       █▌ ▁▁▁ ▐█  ",
        "███╗   ███╗███████╗ ██████╗ ██╗    ██╗██╗    ██╗   ██╗██╗███╗   ███╗   █████████▌  ",
        "████╗ ████║██╔════╝██╔═══██╗██║    ██║██║    ██║   ██║██║████╗ ████║   █ ████ ███  ",
        "██╔████╔██║█████╗  ██║   ██║██║ █╗ ██║██║    ██║   ██║██║██╔████╔██║   ████▄█████▎",
        "██║╚██╔╝██║██╔══╝  ██║   ██║██║███╗██║██║    ╚██╗ ██╔╝██║██║╚██╔╝██║   ███▌█████▔",
        "██║ ╚═╝ ██║███████╗╚██████╔╝╚███╔███╔╝███████╗╚████╔╝ ██║██║ ╚═╝ ██║  ▐███▐█████▎",
        "╚═╝     ╚═╝╚══════╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝ ╚═══╝  ╚═╝╚═╝     ╚═╝  ███▌█████▀",
        "                                                                      █▋ ▐▋▔▋",
        "☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ",
      }

    -- base16 テーマの暖色アクセントで縦グラデーション（base0A → base08、10 step）
    local acc = theme.accents()
    for i = 1, 10 do
      vim.api.nvim_set_hl(0, "AlphaGrad" .. i,
        { fg = theme.lerp_hex(acc.grad_from, acc.grad_to, (i - 1) / 9) })
    end
    vim.api.nvim_set_hl(0, "AlphaButtonText",     { fg = acc.button })
    vim.api.nvim_set_hl(0, "AlphaButtonShortcut", { fg = acc.shortcut, bold = true })
    vim.api.nvim_set_hl(0, "AlphaButtonCursor",   { bg = acc.selbg })

    -- ヘッダー全行に 1..10 のグラデーションを縦方向へ分配
    local _hn = #dashboard.section.header.val
    dashboard.section.header.opts.hl = {}
    for _i = 1, _hn do
      local g = math.floor((_i - 1) / math.max(1, _hn - 1) * 9) + 1
      table.insert(dashboard.section.header.opts.hl, { { "AlphaGrad" .. g, 0, -1 } })
    end
    dashboard.section.header.opts.position = "center"

    local function btn(key, text, cmd)
      local b = dashboard.button(key, "  " .. text, cmd)
      b.opts.hl          = "AlphaButtonText"
      b.opts.hl_shortcut = "AlphaButtonShortcut"
      b.opts.cursor      = 0
      return b
    end

    dashboard.section.buttons.val = {
      btn("n", "New file", "<cmd>ene <bar> startinsert<cr>"),
      btn("o", "Open file", "<cmd>FzfLua files<cr>"),
      btn("t", "Theme", "<cmd>lua require('config.theme').pick()<cr>"),
    }
    dashboard.section.buttons.opts.position = "center"

    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        vim.opt_local.cursorline = true
        vim.api.nvim_set_hl(0, "CursorLine", { bg = theme.accents().selbg })
        start_marquee(vim.api.nvim_get_current_buf())
      end,
    })

    -- alpha を離れたらタイマー停止
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaClosed",
      callback = stop_marquee,
    })

    local usage_lines = get_claude_usage_lines()

    local usage_section = {
      type = "group",
      val = (function()
        if #usage_lines == 0 then
          return {}
        end
        local group = {
          {
            type = "text",
            val = "  Claude usage",
            opts = { position = "center" },
          },
          { type = "padding", val = 1 },
        }
        for _, line in ipairs(usage_lines) do
          table.insert(group, {
            type = "text",
            val = line,
            opts = { position = "center", hl = "AlphaButtonText" },
          })
        end
        return group
      end)(),
    }

    -- PR buttons section
    local function get_pr_buttons()
      if vim.fn.executable("gh") == 0 then
        return {}
      end
      vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
      if vim.v.shell_error ~= 0 then
        return {}
      end

      -- header(3) + paddings(7) + nav buttons(3) + pr title(1) + footer(2) = 16 fixed lines
      local usage_height = #usage_lines > 0 and (#usage_lines + 3) or 0
      local limit = math.max(1, vim.o.lines - 16 - usage_height)
      local raw = vim.fn.system("gh pr list --limit " .. limit .. " --json title,url")
      if vim.v.shell_error ~= 0 then
        return {}
      end

      local ok, prs = pcall(vim.json.decode, raw)
      if not ok or #prs == 0 then
        return {}
      end

      local buttons = {}
      for i, pr in ipairs(prs) do
        -- truncation は行わず全文保持（marquee がスクロールするため）
        local label = "  " .. pr.title
        local url   = pr.url
        local b = {
          type = "button",
          val  = label,
          on_press = function()
            vim.cmd(string.format("silent !open '%s'", url))
          end,
          opts = {
            position   = "center",
            cursor     = 0,
            hl         = "AlphaButtonText",
          },
        }
        b.opts.cursor      = 0
        buttons[i] = b
      end
      return buttons
    end

    local pr_buttons = get_pr_buttons()

    local pr_section = {
      type = "group",
      val = (function()
        if #pr_buttons == 0 then
          return {}
        end
        local group = {
          {
            type = "text",
            val = "  Open PRs",
            opts = { position = "center" },
          },
          { type = "padding", val = 1 },
        }
        for _, b in ipairs(pr_buttons) do
          table.insert(group, b)
        end
        return group
      end)(),
    }

    dashboard.section.footer.val = {}

    alpha.setup({
      layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        usage_section,
        { type = "padding", val = 1 },
        pr_section,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      },
      opts = dashboard.opts.opts,
    })
  end,
},
}
