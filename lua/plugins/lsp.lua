require("mason").setup({})

-- LSP Servers settings
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
        diagnostics = { disable = { "missing-fields" } },
        hint = { enable = true },
      },
    },
  },

  vtsls = {},

  rust_analyzer = {},

  tailwindcss = {},

  cssls = {},

  html = {},
}

local ensure_installed = vim.tbl_keys(servers or {})

-- Other coding tools
vim.list_extend(ensure_installed, {
  "stylua", -- Lua formatter
  "eslint_d", -- JS/TS linter
  "oxfmt", -- js formatter
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

require("mason-lspconfig").setup({ automatic_enable = vim.tbl_keys(servers or {}) })

for server_name, config in pairs(servers) do
  vim.lsp.config(server_name, config)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP:" .. desc })
    end

    local picker = Snacks.picker

    map("gd", picker.lsp_definitions, "Goto Definitions")
    map("gr", picker.lsp_references, "Goto References")
    map("gD", picker.lsp_declarations, "Goto Declaration")
    map("gI", picker.lsp_implementations, "Goto Implementations")
    map("gt", picker.lsp_type_definitions, "Goto Type Definitions")

    map("<leader>ca", vim.lsp.buf.code_action, "Coda Action")
    map("<leader>cr", vim.lsp.buf.rename, "Code Rename")

    map("<leader>fd", picker.diagnostics_buffer, "Find Diagnostics(Buffer)")
    map("<leader>fD", picker.diagnostics, "Find Diagnostics(Workspace)")

    map("K", function()
      vim.lsp.buf.hover({ border = "single" })
    end, "LSP: Hover")
  end,
})

-- =============================================================================
-- Module exports (for fn-triggered pack entries)
-- =============================================================================
local M = {}

function M.lazydev()
  require("lazydev").setup({
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim", words = { "Snacks" } },
    },
    -- disable when a .luarc.json file is found
    enabled = function(root_dir)
      return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
    end,
  })
end

function M.fidget()
  require("fidget").setup()
end

return M
