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
end

return M
