local utils = require("catppuccin.utils.colors")
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  custom_highlights = function(colors)
    return {
      CursorLine = { bg = utils.darken(colors.surface1, 0.75, colors.base) },
      BlinkCmpDoc = { bg = utils.darken(colors.surface0, 0.5, colors.base) },
      BlinkCmpMenu = { bg = colors.surface0 },
      BlinkCmpSignatureHelp = { bg = colors.mantle },
      BlinkCmpSignatureHelpActiveParameter = { bg = colors.surface1, bold = true, italic = true },
      -- NvimTree
      NvimTreeGitStagedIcon = { fg = colors.green },

      SnacksIndent = { fg = colors.surface1 },
    }
  end,
  integrations = {
    blink_cmp = true,
    flash = true,
    diffview = true,
    snacks = {
      enabled = true,
      indent_scope_color = "peach",
    },
  },
})
vim.cmd("colorscheme catppuccin-nvim")
