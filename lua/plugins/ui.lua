local M = {}

function M.which_key()
  require("which-key").setup({
    spec = {
      { "<leader>c", group = "Code", mode = { "n", "x" } },
      { "<leader>f", group = "Find" },
      { "<leader>w", group = "Window" },
      { "<leader>b", group = "Buffer" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
      { "<leader>t", group = "Toggle" },
      { "<leader>u", group = "UI" },
      { "<leader>d", group = "Debug" },
      { "<leader>s", group = "Search" },
    },
  })
end

function M.colorizer()
  require("colorizer").setup({})
  vim.keymap.set("n", "<leader>tc", "<cmd>ColorizerToggle<cr>", {desc = "Toggle colorizer"})
end

function M.bufferline()
  local bufferline = require("bufferline")
  local colors = require("catppuccin.palettes").get_palette("mocha")
  bufferline.setup({
    options = {
      diagnostics = false,
      indicator = {
        style = "icon",
        icon = "▍",
      },
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        },
        {
          filetype = "Outline",
          text = "Outline",
          text_align = "left",
          separator = true,
        },
      },
      show_buffer_close_icons = false,
    },
    highlights = require("catppuccin.special.bufferline").get_theme({
      style = { "italic", "bold" },
      custom = {
        all = {
          buffer_selected = {
            fg = colors.peach,
          },
        },
      },
    }),
  })
end

function M.outline()
  require("outline").setup({})
  vim.keymap.set("n", "<leader>to", "<cmd>Outline<cr>", { desc = "Toggle outline" })
end

function M.todo_comment()
  require("todo-comments").setup({})
  vim.keymap.set("n", "<leader>ft", "<cmd>TodoQuickFix<cr>", {desc = "Find TODO"})
end

return M
