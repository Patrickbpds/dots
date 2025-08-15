local heimdall_ok, heimdall_module = pcall(require, "user.heimdall")
local colors = {}
local color_overrides = {}

if heimdall_ok and type(heimdall_module) == "table" then
  colors = heimdall_module.colors or {}
  color_overrides = heimdall_module.color_overrides or {}
end

local function setup_catppuccin(new_colors, new_color_overrides)
  new_colors = new_colors or colors
  new_color_overrides = new_color_overrides or color_overrides
  require("catppuccin").setup({
    float = { transparent = false, solid = false },
    transparent_background = true,
    term_colors = false,
    color_overrides = new_color_overrides,
    integrations = {
      blink_cmp = true,
      neotree = true,
    },
  })
end

local function setup_lualine(new_colors)
  new_colors = new_colors or colors
  local lualine = require("lualine")

  local conditions = {
    buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
      local filepath = vim.fn.expand("%:p:h")
      local gitdir = vim.fn.finddir(".git", filepath .. ";")
      return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
  }

  local config = {
    options = {
      component_separators = "",
      section_separators = "",
      theme = {
        normal = { c = { fg = new_colors.text, bg = new_colors.base } },
        inactive = { c = { fg = new_colors.text, bg = new_colors.base } },
      },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
  }

  local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  ins_left({
    function()
      return ""
    end,
    color = function()
      local mode_color = {
        n = new_colors.blue,
        i = new_colors.mauve,
        v = new_colors.pink,
        [""] = new_colors.pink,
        V = new_colors.pink,
        c = new_colors.green,
        no = new_colors.blue,
        s = new_colors.peach,
        S = new_colors.peach,
        [""] = new_colors.peach,
        ic = new_colors.red,
        R = new_colors.lavender,
        RR = new_colors.lavender,
        cv = new_colors.blue,
        ce = new_colors.blue,
        r = new_colors.teal,
        rm = new_colors.teal,
        ["r?"] = new_colors.teal,
        ["!"] = new_colors.blue,
        t = new_colors.blue,
      }
      return { fg = mode_color[vim.fn.mode()] }
    end,
  })

  ins_left({
    function()
      return ""
    end,
    color = function()
      local mode_color = {
        n = new_colors.blue,
        i = new_colors.mauve,
        v = new_colors.pink,
        [""] = new_colors.pink,
        V = new_colors.pink,
        c = new_colors.green,
        no = new_colors.blue,
        s = new_colors.peach,
        S = new_colors.peach,
        [""] = new_colors.peach,
        ic = new_colors.red,
        R = new_colors.lavender,
        RR = new_colors.lavender,
        cv = new_colors.blue,
        ce = new_colors.blue,
        r = new_colors.teal,
        rm = new_colors.teal,
        ["r?"] = new_colors.teal,
        ["!"] = new_colors.blue,
        t = new_colors.blue,
      }
      return { fg = mode_color[vim.fn.mode()] }
    end,
  })

  ins_left({
    "filename",
    cond = conditions.buffer_not_empty,
    color = { fg = new_colors.lavender, gui = "bold" },
  })

  ins_left({
    function()
      return "|"
    end,
    color = { fg = new_colors.surface0 },
  })

  ins_left({ "location", color = { fg = new_colors.overlay0 } })

  ins_left({ "progress", color = { fg = new_colors.overlay0, gui = "bold" } })

  ins_left({
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
    diagnostics_color = {
      color_error = { fg = new_colors.red },
      color_warn = { fg = new_colors.yellow },
      color_info = { fg = new_colors.teal },
    },
  })

  ins_left({
    function()
      return "%="
    end,
  })

  ins_left({
    "buffers",
    hide_filename_extension = true,
    mode = 1,
    max_length = vim.o.columns * 0.25,
    buffers_color = {
      active = { fg = new_colors.mauve },
      inactive = { fg = new_colors.surface0 },
    },
  })

  ins_right({
    "branch",
    icon = "  ",
    color = { fg = new_colors.lavender, gui = "bold" },
  })

  ins_right({
    function()
      local msg = "no lsp"
      local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
      local clients = vim.lsp.get_clients()
      if next(clients) == nil then
        return msg
      end
      for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
          return client.name
        end
      end
      return msg
    end,
    icon = "  ",
    color = { fg = new_colors.lavender, gui = "bold" },
  })

  ins_right({
    function()
      return "|"
    end,
    color = { fg = new_colors.surface0 },
  })

  ins_right({
    "o:encoding",
    cond = conditions.hide_in_width,
    color = { fg = new_colors.blue, gui = "bold" },
  })

  ins_right({
    function()
      return ""
    end,
    color = { fg = new_colors.blue },
  })

  ins_right({
    "fileformat",
    icons_enabled = true,
    color = { fg = new_colors.blue, gui = "bold" },
  })

  lualine.setup(config)
  return config
end

local function setup_incline(new_colors)
  new_colors = new_colors or colors
  require("incline").setup({
    window = {
      padding = 0,
      margin = { horizontal = 0 },
    },
    render = function(props)
      local lazy_icons = LazyVim.config.icons
      local mini_icons = require("mini.icons")

      local function get_filename()
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end
        local ft_icon, ft_color = mini_icons.get("file", filename)
        local modified = vim.bo[props.buf].modified
        return {
          " ",
          { filename, gui = modified and "bold,italic" or "bold" },
          " ",
          ft_icon and { ft_icon, " ", guibg = "none", group = ft_color } or "",
        }
      end

      local function get_diagnostics()
        local icons = {
          error = lazy_icons.diagnostics.Error,
          warn = lazy_icons.diagnostics.Warn,
          info = lazy_icons.diagnostics.Info,
          hint = lazy_icons.diagnostics.Hint,
        }
        local labels = {}

        for severity, icon in pairs(icons) do
          local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
          if n > 0 then
            table.insert(labels, { " " .. icon .. n, group = "DiagnosticSign" .. severity })
          end
        end
        if #labels > 0 then
          table.insert(labels, { " |" })
        end
        return labels
      end

      local function get_grapple_status()
        local grapple_status
        grapple_status = require("grapple").name_or_index({ buffer = props.buf }) or ""
        if grapple_status ~= "" then
          grapple_status = { { " 󰛢 ", guifg = colors.sky }, { grapple_status, guifg = colors.sky } }
        end
        return grapple_status
      end

      return {
        { get_diagnostics() },
        { get_grapple_status() },
        { get_filename() },
        guibg = props.focused and colors.mantle or colors.surface0,
      }
    end,
  })
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = setup_catppuccin,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = setup_lualine,
  },
  {
    "b0o/incline.nvim",
    name = "incline",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    dependencies = { "mini.icons" },
    opts = setup_incline,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
    init = function()
      local user_dir = vim.fn.stdpath("config") .. "/lua/user/"
      local heimdall_file = user_dir .. "heimdall.lua"

      local last_mtime = 0

      local function check_and_reload_heimdall()
        if vim.fn.filereadable(heimdall_file) ~= 1 then
          return
        end

        local current_mtime = vim.fn.getftime(heimdall_file)

        if current_mtime == -1 then
          return
        end

        if current_mtime > last_mtime then
          last_mtime = current_mtime

          package.loaded["user.heimdall"] = nil
          package.loaded["catppuccin"] = nil
          package.loaded["lualine"] = nil
          package.loaded["incline"] = nil

          vim.defer_fn(function()
            local reloaded_heimdall_ok, reloaded_heimdall_module = pcall(require, "user.heimdall")
            local new_colors = {}
            local new_color_overrides = {}

            if reloaded_heimdall_ok and type(reloaded_heimdall_module) == "table" then
              new_colors = reloaded_heimdall_module.colors or {}
              new_color_overrides = reloaded_heimdall_module.color_overrides or {}
            end

            setup_catppuccin(new_colors, new_color_overrides)
            setup_lualine(new_colors)
            setup_incline(new_colors)

            vim.cmd(":silent! colorscheme catppuccin-mocha")
            vim.cmd(":silent! doautocmd ColorScheme")

            vim.notify(
              "Theme updated! Colorscheme, Lualine, Incline reloaded.",
              vim.log.levels.INFO,
              { title = "Auto Reload" }
            )
          end, 100)
        end
      end

      local timer = vim.uv.new_timer()
      local timer_interval_ms = 500

      timer:start(timer_interval_ms, timer_interval_ms, vim.schedule_wrap(check_and_reload_heimdall))

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          timer:stop()
          timer:close()
        end,
      })
    end,
  },
  { "yamatsum/nvim-nonicons" },
}
