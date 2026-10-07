local lualine = require("lualine")
local colors = require("catppuccin.palettes").get_palette("mocha")

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
}

local mode_map = {
  -- See :help mode()
  ["n"] = { icon = " ", color = colors.teal },
  ["no"] = { icon = " ", color = colors.sapphire },
  ["nov"] = { icon = " ", color = colors.sapphire },
  ["noV"] = { icon = " ", color = colors.sapphire },
  ["no\22"] = { icon = " ", color = colors.sapphire },
  ["niI"] = { icon = " ", color = colors.teal },
  ["niR"] = { icon = " ", color = colors.teal },
  ["niV"] = { icon = " ", color = colors.teal },
  ["nt"] = { icon = " ", color = colors.teal },
  ["ntT"] = { icon = " ", color = colors.teal },
  ["v"] = { icon = " ", color = colors.mauve },
  ["vs"] = { icon = " ", color = colors.mauve },
  ["V"] = { icon = " LINE", color = colors.pink },
  ["Vs"] = { icon = " LINE", color = colors.pink },
  ["\22"] = { icon = " BLOCK", color = colors.pink },
  ["\22s"] = { icon = " BLOCK", color = colors.pink },
  ["s"] = { icon = "󰫙 ", color = colors.flamingo },
  ["S"] = { icon = "󰫙 LINE", color = colors.flamingo },
  ["\19"] = { icon = "󰫙 BLOCK", color = colors.flamingo },
  ["i"] = { icon = " ", color = colors.green },
  ["ic"] = { icon = " ", color = colors.green },
  ["ix"] = { icon = " ", color = colors.green },
  ["R"] = { icon = " ", color = colors.yellow },
  ["Rc"] = { icon = " ", color = colors.yellow },
  ["Rx"] = { icon = " ", color = colors.yellow },
  ["Rv"] = { icon = " V", color = colors.yellow },
  ["Rvc"] = { icon = " V", color = colors.yellow },
  ["Rvx"] = { icon = " V", color = colors.yellow },
  ["c"] = { icon = " ", color = colors.peach },
  ["cv"] = { icon = "EX", color = colors.peach },
  ["ce"] = { icon = "EX", color = colors.peach },
  ["r"] = { icon = "REPLACE", color = colors.yellow },
  ["rm"] = { icon = "MORE", color = colors.peach },
  ["r?"] = { icon = "CONFIRM", color = colors.peach },
  ["!"] = { icon = "SHELL", color = colors.peach },
  ["t"] = { icon = "TERMINAL", color = colors.peach },
}

local config = {
  options = {
    component_separators = "",
    section_separators = { left = "" },
    -- always_show_tabline = true,
    globalstatus = true,
    theme = {
      normal = {
        a = { fg = colors.base, bg = colors.green, gui = "bold" },
        b = { fg = colors.text, bg = colors.surface0 },
        c = { fg = colors.text, bg = colors.mantle },
      },
      inactive = {
        a = { fg = colors.text, bg = colors.surface0, gui = "bold" },
        b = { fg = colors.text, bg = colors.surface1 },
        c = { fg = colors.text, bg = colors.mantle },
      },
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- fill components
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      { "filename", path = 1 },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  extensions = {
    "nvim-tree",
    "mason",
    "symbols-outline",
  },
}

local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

-- mode indicator
ins_left({
  function()
    local mode_code = vim.api.nvim_get_mode().mode
    if mode_map[mode_code] == nil then
      return mode_code
    end
    return "" .. mode_map[mode_code].icon .. ""
  end,
  color = function()
    local mode_code = vim.api.nvim_get_mode().mode
    if mode_map[mode_code] == nil then
      return { fg = colors.surface2, bg = colors.base, gui = "bold" }
    end
    return { fg = mode_map[mode_code].color, gui = "bold" }
  end,
  padding = { left = 1, right = 1 },
})
ins_left({
  "filename",
  path = 1,
  cond = conditions.buffer_not_empty,
  color = { fg = colors.peach, gui = "bold" },
})
ins_left({
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = {
    error = " ",
    warn = " ",
    info = " ",
    hint = "󰌵 ",
  },
  diagnostics_color = {
    color_error = { fg = colors.red },
    color_warn = { fg = colors.yellow },
    color_info = { fg = colors.sapphire },
    color_hint = { fg = colors.blue },
  },
})
-- macro-recording indicator
ins_left({
  function()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
      return ""
    else
      return "󰑋 " .. recording_register
    end
  end,
  color = { fg = colors.red, gui = "bold" },
})
ins_right({
  "encoding",
  format = string.upper,
  color = { fg = colors.sapphire, gui = "bold" },
  -- cond = conditions.hide_in_width,
})

ins_right({
  "fileformat",
  fmt = string.upper,
  icons_enabled = false,
  color = { fg = colors.green, gui = "bold" },
  -- cond = conditions.hide_in_width,
})

ins_right({
  "lsp_status",
  icon = "",
  color = { fg = colors.sky },
})

ins_right({
  function()
    local ok, lint = pcall(require, "lint")

    if not ok then
      return ""
    end

    local linters = lint.get_running()

    if #linters == 0 then
      return "󰦕"
    end

    return "󱉶 " .. table.concat(linters, ", ")
  end,
  color = { fg = colors.maroon },
  -- cond = conditions.hide_in_width,
})

ins_right({
  "location",
  color = { fg = colors.mauve },
  -- cond = conditions.hide_in_width,
})

ins_right({
  "progress",
  color = { fg = colors.rosewater },
  -- cond = conditions.hide_in_width,
})

ins_right({
  "branch",
  icon = "",
  color = { fg = colors.mauve, gui = "bold" },
})

ins_right({
  "diff",
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.yellow },
    removed = { fg = colors.red },
  },
  symbols = { added = " ", modified = " ", removed = " " },
})

lualine.setup(config)
