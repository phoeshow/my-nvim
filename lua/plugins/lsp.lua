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
}

local ensure_installed = vim.tbl_keys(servers or {})

-- Other coding tools
vim.list_extend(ensure_installed, {
  "stylua", -- Lua formatter
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

require("mason-lspconfig").setup({ automatic_enable = vim.tbl_keys(servers or {}) })

for server_name, config in pairs(servers) do
  vim.lsp.config(server_name, config)
end

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
  })
end

return M
