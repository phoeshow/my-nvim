vim.pack.add({
  -- Colorscheme
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

  -- Dependencies
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- File Explorer
  "https://github.com/nvim-tree/nvim-tree.lua",

  -- Snacks
  "https://github.com/folke/snacks.nvim",

  -- Which-key
  "https://github.com/folke/which-key.nvim",

  -- Flash
  "https://github.com/folke/flash.nvim",

  -- Statusline
  "https://github.com/rebelot/heirline.nvim",
  "https://github.com/akinsho/bufferline.nvim",

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

  -- LSP
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/folke/lazydev.nvim",

  -- Blink.cmp
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",

  -- Formatting
  "https://github.com/stevearc/conform.nvim",

  -- Linter
  "https://github.com/mfussenegger/nvim-lint",

  -- Auto pairs
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",

  -- Git
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",

  -- show color text
  "https://github.com/catgoose/nvim-colorizer.lua",
}, {
  confirm = false,
  load = function() end,
})

local pack = require("core.pack")

pack.setup({
  -- -------------------------------------------------------------------------
  -- Immediate
  -- -------------------------------------------------------------------------
  { mod = "catppuccin", packadd = { "catppuccin" } },

  -- -------------------------------------------------------------------------
  -- VimEnter (non-blocking — loads after init but before UI renders)
  -- -------------------------------------------------------------------------
  { mod = "snacks", event = "VimEnter", packadd = { "snacks.nvim" } },
  { mod = "nvim-tree", event = "VimEnter", packadd = { "nvim-web-devicons", "nvim-tree.lua" } },

  -- -------------------------------------------------------------------------
  -- UIEnter (non-blocking — loads after first frame renders)
  -- -------------------------------------------------------------------------
  -- { mod = "lualine", event = "UIEnter", packadd = { "lualine.nvim" }},
  { mod = "heirline", event = "UIEnter", packadd = { "heirline.nvim" } },
  { mod = "ui", fn = "which_key", event = "UIEnter", packadd = { "which-key.nvim" } },

  -- -------------------------------------------------------------------------
  -- BufReadPre / BufNewFile (core file-level features)
  -- -------------------------------------------------------------------------
  { mod = "lsp", event = { "BufReadPre", "BufNewFile" }, packadd = { "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim", "mason-tool-installer.nvim" } },
  { mod = "lsp", fn = "lazydev", event = { "BufReadPre", "BufNewFile" }, pattern = { "*.lua" }, packadd = { "lazydev.nvim" } },
  { mod = "editing", fn = "autotag", event = { "BufReadPre", "BufNewFile" }, packadd = { "nvim-ts-autotag" } },
  { mod = "treesitter", event = { "BufReadPre", "BufNewFile" }, packadd = { "nvim-treesitter" } },
  { mod = "git", fn = "gitsigns", event = { "BufReadPre", "BufNewFile" }, packadd = { "gitsigns.nvim" } },
  { mod = "editing", fn = "flash", event = { "BufReadPre", "BufNewFile" }, packadd = { "flash.nvim" } },
  { mod = "editing", fn = "lint", event = { "BufReadPre", "BufNewFile" }, packadd = { "nvim-lint" } },
  { mod = "ui", fn = "colorizer", event = { "BufReadPre", "BufNewFile" }, packadd = { "nvim-colorizer.lua" } },
  { mod = "ui", fn = "bufferline", event = { "BufReadPre", "BufNewFile" }, packadd = { "bufferline.nvim" } },

  -- -------------------------------------------------------------------------
  -- InsertEnter / CmdlineEnter (completion)
  -- -------------------------------------------------------------------------
  { mod = "editing", fn = "autopairs", event = { "InsertEnter", "CmdlineEnter" }, packadd = { "nvim-autopairs" } },
  { mod = "completion", event = { "InsertEnter", "CmdlineEnter" }, packadd = { "friendly-snippets", "blink.lib", "blink.cmp" } },

  --  -- -------------------------------------------------------------------------
  -- BufWritePre (formatting on save — conform has its own internal guard)
  -- -------------------------------------------------------------------------
  { mod = "editing", fn = "format", event = { "BufWritePre" }, packadd = { "conform.nvim" } },

  -- -------------------------------------------------------------------------
  -- Keymap-triggered (first keypress loads the module, then replays the key)
  -- -------------------------------------------------------------------------
  {
    mod = "git",
    fn = "diffview",
    keys = {
      { "<leader>gd", desc = "Open Diffview" },
      { "<leader>gh", desc = "View current file history" },
    },
    packadd = { "diffview.nvim" },
  },

  -- -------------------------------------------------------------------------
  -- Deferred (idle — load after defer ms)
  -- -------------------------------------------------------------------------
})
