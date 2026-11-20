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
    formatters = {
      oxfmt = {
        prepend_args = function(self, ctx)
          -- 优先查找当前项目是否有独立配置
          local has_local = vim.fs.find({ ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }, { upward = true, path = ctx.dirname })[1]
          if not has_local then
            return { "--config", vim.fn.expand("~/.config/nvim/.oxfmtrc.json") }
          end
          return {}
        end,
      },
    },
  })
end

function M.lint()
  local lint = require("lint")
  lint.linters_by_ft = {
    markdown = { "markdownlint" },
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescriptreact = { "eslint_d" },
  }

  -- 动态指定 markdownlint 配置文件：优先项目本地，否则回退到 nvim 目录
  local markdownlint = lint.linters.markdownlint
  markdownlint.args = {
    "--config",
    function()
      local local_cfg = vim.fs.find({ ".markdownlint.json", ".markdownlint.jsonc", ".markdownlintrc" }, { upward = true, path = vim.fn.expand("%:p:h") })[1]
      return local_cfg or vim.fn.expand("~/.config/nvim/.markdownlint.json")
    end,
    "--",
  }

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

function M.grug_far()
  require("grug-far").setup({
    headerMaxWidth = 80,
  })

  vim.keymap.set({ "n", "v" }, "<leader>sr", function()
    local grug = require("grug-far")
    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")

    grug.open({
      transient = true,
      prefills = {
        filesFilter = ext and ext ~= "" and "*." .. ext or nil,
      },
    })
  end, { desc = "Search and Replace" })
end

return M
