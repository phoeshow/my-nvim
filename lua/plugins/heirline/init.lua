local heirline = require("heirline")
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local devicons = require("nvim-web-devicons")

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------
local function setup_colors()
  local c = require("catppuccin.palettes").get_palette()
  return {
    base = c.base,
    mantle = c.mantle,
    crust = c.crust,
    surface0 = c.surface0,
    surface1 = c.surface1,
    surface2 = c.surface2,
    overlay0 = c.overlay0,
    overlay1 = c.overlay1,
    overlay2 = c.overlay2,
    text = c.text,
    subtext0 = c.subtext0,
    subtext1 = c.subtext1,
    rosewater = c.rosewater,
    flamingo = c.flamingo,
    pink = c.pink,
    mauve = c.mauve,
    red = c.red,
    maroon = c.maroon,
    peach = c.peach,
    yellow = c.yellow,
    green = c.green,
    teal = c.teal,
    sky = c.sky,
    sapphire = c.sapphire,
    blue = c.blue,
    lavender = c.lavender,
    diag_error = c.red,
    diag_warn = c.yellow,
    diag_info = c.sky,
    diag_hint = c.sky,
  }
end

heirline.load_colors(setup_colors())

heirline.setup({
  statusline = require("plugins.heirline.statusline"),
  winbar = require("plugins.heirline.winbar"),
  tabline = require("plugins.heirline.tabline"),
  opts = {
    disable_winbar_cb = function(args)
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = {
          "^git.*",
          "fugitive",
          "Trouble",
          "lazy",
          "alpha",
          "dashboard",
          "NvimTree",
        },
      }, args.buf)
    end,
  },
})
