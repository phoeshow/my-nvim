-- See `:help vim.opt`
-- NOTE: For more options,see `:help option-list`

-- Line number
vim.o.number = true
vim.o.relativenumber = true

-- Open signcolumn
vim.o.signcolumn = "yes"

-- Offset
vim.o.scrolloff = 8
vim.o.sidescrolloff = 5

-- Mouse mode
vim.o.mouse = "a"

-- Sync clipboard
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Indent
vim.o.breakindent = true
vim.o.autoindent = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Split window
vim.o.splitright = true
vim.o.splitbelow = true

-- <tab>
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.softtabstop = 2
vim.o.tabstop = 2

-- Wrap
vim.o.wrap = false
vim.o.whichwrap = "<,>,[,]"

-- whitespace display
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

--- [[UI]]
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.cursorline = true
vim.o.showtabline = 2

-- Decrease update time
vim.o.updatetime = 250
-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Fold
vim.o.foldenable = false

-- Encoding
vim.o.encoding = "utf-8"
vim.o.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"

-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = "single", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
  virtual_text = true,
  virtual_lines = false,
  -- Auto open the float,so you can easily read the errors when jumping with '[d' and ']d'
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})
