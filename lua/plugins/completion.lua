local cmp = require("blink.cmp")

-- cmp.build():pwait()

cmp.setup({
  -- markdown 中不启用补全（菜单/签名帮助），cmdline 补全不受影响
  enabled = function()
    return vim.bo.filetype ~= "markdown"
  end,
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
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
