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
    },
  })
end

function M.autopairs()
  require("nvim-autopairs").setup({})
end

function M.autotag()
  require("nvim-ts-autotag").setup({})
end

return M
