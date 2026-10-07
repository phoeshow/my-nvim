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

function M.lint()
  local lint = require("lint")
  lint.linters_by_ft = {
    -- markdown = { "markdownlint" },
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescriptreact = { "eslint_d" },
  }

  -- To allow other plugins to add linters to require('lint').linters_by_ft,
  -- instead set linters_by_ft like this:
  -- lint.linters_by_ft = lint.linters_by_ft or {}
  -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
  --
  -- However, note that this will enable a set of default linters,
  -- which will cause errors unless these tools are available:
  -- {
  --   clojure = { "clj-kondo" },
  --   dockerfile = { "hadolint" },
  --   inko = { "inko" },
  --   janet = { "janet" },
  --   json = { "jsonlint" },
  --   markdown = { "vale" },
  --   rst = { "vale" },
  --   ruby = { "ruby" },
  --   terraform = { "tflint" },
  --   text = { "vale" }
  -- }
  --
  -- You can disable the default linters by setting their filetypes to nil:
  -- lint.linters_by_ft['clojure'] = nil
  -- lint.linters_by_ft['dockerfile'] = nil
  -- lint.linters_by_ft['inko'] = nil
  -- lint.linters_by_ft['janet'] = nil
  -- lint.linters_by_ft['json'] = nil
  -- lint.linters_by_ft['markdown'] = nil
  -- lint.linters_by_ft['rst'] = nil
  -- lint.linters_by_ft['ruby'] = nil
  -- lint.linters_by_ft['terraform'] = nil
  -- lint.linters_by_ft['text'] = nil

  -- Create autocommand which carries out the actual linting
  -- on the specified events.
  local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
      -- Only run the linter in buffers that you can modify in order to
      -- avoid superfluous noise, notably within the handy LSP pop-ups that
      -- describe the hovered symbol using Markdown.
      if vim.opt_local.modifiable:get() then
        lint.try_lint()
      end
    end,
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
