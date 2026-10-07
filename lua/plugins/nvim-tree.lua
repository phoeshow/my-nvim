local nvimtree = require("nvim-tree")

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")
  local function opts(desc)
    return { desc = desc, buf = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.map.on_attach.default(bufnr)

  -- replace show help map
  vim.keymap.del("n", "g?", { buf = bufnr })
  vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
  -- replace split open
  vim.keymap.del("n", "<C-x>", { buf = bufnr })
  vim.keymap.set("n", "<C-s>", api.node.open.horizontal, opts("Open: Vertical Split"))
  -- remove open in new tab
  vim.keymap.del("n", "<C-t>", { buf = bufnr })
end

nvimtree.setup({
  actions = {
    open_file = {
      quit_on_open = true,
      window_picker = {
        exclude = {
          filetype = { "Outline" },
        },
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
    highlight_hidden = "name",
    highlight_modified = "name",
    icons = {
      glyphs = {
        git = {
          untracked = "󰯫",
          unstaged = "󰰏",
          staged = "",
          ignored = "",
          unmerged = "󰯱",
        },
      },
    },
  },
  on_attach = my_on_attach,
  filters = {
    dotfiles = true,
    git_ignored = false,
  },
})

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Open File Explorer" })

local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
vim.api.nvim_create_autocmd("User", {
  pattern = "NvimTreeSetup",
  callback = function()
    local events = require("nvim-tree.api").events
    events.subscribe(events.Event.NodeRenamed, function(data)
      if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
        data = data
        Snacks.rename.on_rename_file(data.old_name, data.new_name)
      end
    end)
  end,
})
