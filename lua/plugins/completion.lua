local cmp = require("blink.cmp")

cmp.build():pwait()

cmp.setup({
  keymap = {
    preset = "enter",
    ["<C-space>"] = {},
    ["<C-s>"] = { "show", "show_documentation", "hide_documentation" },
  },
  completion = {
    accept = { auto_brackets = { enabled = true } },
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "rust" },
})
