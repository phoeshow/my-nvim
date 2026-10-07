local M = {}

function M.format()
  require("conform").setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = {
        -- c = true,
        -- cpp = true
      }

      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "oxfmt" },
      typescript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      markdown = { "oxfmt" },
      html = { "oxfmt" },
      yaml = { "oxfmt" },
      toml = { "oxfmt" },
      css = { "oxfmt" },
      json = { "oxfmt" },
      jsonc = { "oxfmt" },
    },
  })
end

function M.autopairs()
  require("nvim-autopairs").setup({})
end

function M.autotag()
  require("nvim-ts-autotag").setup({})
end

function M.flash()
  require("flash").setup()
  vim.keymap.set({ "n", "x", "o" }, "s", function()
    require("flash").jump()
  end, { desc = "Flash" })

  vim.keymap.set({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
  end, { desc = "Flash Treesitter" })
end

return M
