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

return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "▄▀▀▄█▄     ▄▄█▓▄▄▄ ▄▀▀▀▀▀▀▀▒▒▄   ├▄▄▄░─┐     ▒▄▄─┐   ▄▄░▓▄▄▄▒▒▄▄     ▄▄▄            ▄▄▓▄■▄   ▒▄▄    ▀▒▄  ▄▀▀▄█▄     ▄▄█▓▄▄▄   █       █",
        "▀▄░▓▌▄░▄  ▐▒▓▓▒▒░▓ ▀▄ ▓     ▀▓▌  ├░▒▓█ █     ▓▓▓▓▌  ░▒▓█▐█▒▀▐▓▓▓▓   ▓▓▓▓▌          ├▐█▓░▌▐▓  ▓▓▓▓▌  ▓▓▓▓ ▀▄░▓▌▄░▄  ▐▒▓▓▒▒░▓   ██     ██",
        " ■▐▀ ▐█░▓▄▒▓▓▀▀▀▀▀   ▐▀   ▄▌ ▀   ▀▀▀▀▀▐■    ┌▀▀▀▀▀  ▀▀▀▀░▀   ▀▀▀▀   ▀▀▀▀           ├▀▀▀▀ ▒▌  ▀▀▀▀▀  ▀▀▀▀  ■▐▀ ▐█░▓▄▒▓▓▀▀▀▀▀   ██████████",
        "▀▄██▄ ▓▒░░▒▓▀ ████   ██▀▀█▀      ████▌'     │▐████ ████▒░    ▐████ ████▌           ├▄▄▄▀▄▀   █████ ▄████ ▀▄██▄ ▓▒░░▒▓▀ ████   █ ████ ███",
        " ▐▓▓▓▓▀▒▓▒█▌ ▓▓▓▓▌  ▐▓▓          ▓▓▓▓┌┘     │▐▓▓▓▓ ▓▓▓▓░     ▐▓▓▓▓ ▓▓▓▓▌           █▀▄▄▄┌┘   ▓▓▓▓▓ ▐▓▓▓▓  ▐▓▓▓▓▀▒▓▒█▌ ▓▓▓▓▌   ████▄██████",
        " ▐▒▒▒▌ ▐▒░▓  ▒▒▒▒▌  ▀▒▒          ▒▒▒▒▌│ ░▌  ░▓▒▒▒▒ ▒▒▒▒▌    ░▒▒▒▒▒ ▒▒▒▒▌           ▐▌▒▒▌┤   ░▒▒▒▒▌ ▐▒▒▒▒  ▐▒▒▒▌ ▐▒░▓  ▒▒▒▒▌   ███ █████",
        " ▐░░▐   ▌░▌  ▐░░░▌   ░░      ▀▄  ▐░░░▌:▒█░▌░█▌░░░▌ ▐░░░▌   ░▒▌░░░▌ ▐░░░▌            ▌░░▌┤  ░█░░░▌  ▐░░░▌  ▐░░▐   ▌░▌  ▐░░░▌  ████ ██████",
        " ▐██▐    ▀    ███▌  ▐██▄     ▐█▌ └████▓▀██░▄█████   ████ ░▒▓▓████   ████      ▄▄▄   └▄██┤░▒▓███▀   ▐███   ▐██▐    ▀    ███▌  ███ ██████",
        "▄████▀         ▀█▌ ▄█████▄▄▄▄█▀  └┬▀▀█░▒▀ ▀▒░█▀▀     ▀▀██▀▀▀██▀▀     ▀▀██▄▄██▀▀  ▀    ▀██▀▀██▄▀    ▐█▀▀  ▄████▀         ▀█▌  █  ██ █",
        "☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ☆彡｡.:・*ﾟ",
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

    -- PR buttons section
    local function get_pr_buttons()
      if vim.fn.executable("gh") == 0 then
        return {}
      end
      vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
      if vim.v.shell_error ~= 0 then
        return {}
      end

      -- header(3) + paddings(7) + nav buttons(2) + pr title(1) + footer(2) = 15 fixed lines
      local limit = math.max(1, vim.o.lines - 15)
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
        pr_section,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      },
      opts = dashboard.opts.opts,
    })
  end,
},
}
