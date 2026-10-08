local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

-- ---------------------------------------------------------------------------
-- Primitives
-- ---------------------------------------------------------------------------
local Space = { provider = " " }
local Align = { provider = "%=" }

-- ---------------------------------------------------------------------------
-- Mode
-- ---------------------------------------------------------------------------
local Mode = utils.surround({ "", "" }, function(self)
  return self:mode_color()
end, {
  {
    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    static = {
      mode_icons = {
        n = " ",
        no = " ",
        nov = " ",
        noV = " ",
        ["no\22"] = " ",
        niI = " ",
        niR = " ",
        niV = " ",
        nt = " ",
        v = "󰒉 ",
        vs = "󰒉 ",
        V = "󰒉 LINE",
        Vs = "󰒉 LINE",
        ["\22"] = "󰒉 BLOCK",
        ["\22s"] = "󰒉 BLOCK",
        s = "󰫙 ",
        S = "󰫙 LINE",
        ["\19"] = "󰫙 BLOCK",
        i = " ",
        ic = " ",
        ix = " ",
        R = " ",
        Rc = " ",
        Rx = " ",
        Rv = " V",
        Rvc = " V",
        Rvx = " V",
        c = " CMD",
        cv = " CMD",
        r = "REPLACE",
        rm = "MORE",
        ["r?"] = "CONFIRM",
        ["!"] = "SHELL",
        t = "TERM",
      },
    },
    provider = function(self)
      return "%2(" .. self.mode_icons[self.mode] .. "%)"
    end,
    hl = function(self)
      return { fg = self:mode_color(), bg = "mantle" }
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
  },
})

-- ---------------------------------------------------------------------------
-- FileNameBlock
-- ---------------------------------------------------------------------------
local FileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
}
local FileName = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":t")
    if filename == "" then
      return "[No Name]"
    end
    return filename
  end,
  hl = { fg = "peach" },
}

local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = "[+]",
    hl = { fg = "green" },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = " ",
    hl = { fg = "red" },
  },
}

local FileNameModifer = {
  hl = function()
    if vim.bo.modified then
      return { fg = "sapphire", bold = true, force = true }
    end
  end,
}

FileNameBlock = utils.insert(FileNameBlock, utils.insert(FileNameModifer, FileName), FileFlags, { provider = "%<" })

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------
local Diagnostics = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = "󰅚 ",
    warn_icon = "󰀪 ",
    info_icon = "󰋽 ",
    hint_icon = "󰌶 ",
  },
  hl = { bg = "mantle" },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  end,
  update = { "DiagnosticChanged", "BufEnter" },
  {
    provider = function(self)
      return self.errors > 0 and (" " .. self.error_icon .. self.errors) or ""
    end,
    hl = { fg = "diag_error" },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (" " .. self.warn_icon .. self.warnings) or ""
    end,
    hl = { fg = "diag_warn" },
  },
  {
    provider = function(self)
      return self.info > 0 and (" " .. self.info_icon .. self.info) or ""
    end,
    hl = { fg = "diag_info" },
  },
  {
    provider = function(self)
      return self.hints > 0 and (" " .. self.hint_icon .. self.hints) or ""
    end,
    hl = { fg = "diag_hint" },
  },
}

local MacroRec = {
  condition = function()
    return vim.fn.reg_recording() ~= ""
  end,
  update = {
    "RecordingEnter",
    "RecordingLeave",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
  {
    provider = "󰑋 ",
    hl = { fg = "red", bold = true },
  },
  utils.surround({ "[", "]" }, "", {
    provider = function()
      return vim.fn.reg_recording()
    end,
    hl = { fg = "red", bold = true },
  }),
}

local FileEncoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
    return enc:upper()
  end,
  hl = { fg = "sapphire", bold = true },
}
local FileFormat = {
  provider = function()
    local fmt = vim.bo.fileformat
    if fmt == "unix" then
      return "UNIX"
    end
    if fmt == "dos" then
      return "CRLF"
    end
    if fmt == "mac" then
      return "CR"
    end
  end,
  hl = { fg = "green", bold = true },
}
local LSPActive = {
  condition = conditions.lsp_attached,
  update = { "LspAttach", "LspDetach" },
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      table.insert(names, server.name)
    end
    return " [" .. table.concat(names, " ") .. "]"
  end,
  hl = { fg = "sky" },
}
local Location = {
  provider = "%l/%L:%c %P ",
  hl = { fg = "pink" },
}
local Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,

  hl = { fg = "mauve" },

  { -- git branch name
    provider = function(self)
      return " " .. self.status_dict.head
    end,
    hl = { bold = true },
  },
  -- You could handle delimiters, icons and counts similar to Diagnostics
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = "(",
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count)
    end,
    hl = { fg = "green" },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count)
    end,
    hl = { fg = "red" },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count)
    end,
    hl = { fg = "yellow" },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = ")",
  },
}

local FileType = {
  provider = function()
    return string.upper(vim.bo.filetype)
  end,
  hl = { fg = utils.get_highlight("Type").fg, bold = true },
}

local SpecialStatusline = {}
local TerminalStatusline = {}
local InactiveStatusline = {
  condition = conditions.is_not_active,
  FileType,
  Space,
  {
    provider = function ()
      local path = vim.fn.expand('%:.')
      return path
    end,
    hl = {fg = "blue",bold = true}
  },
  Align,
}
local DefaultStatusline = {
  Mode,
  Space,
  FileNameBlock,
  Space,
  Diagnostics,
  Space,
  MacroRec,
  Align,
  FileEncoding,
  Space,
  FileFormat,
  Space,
  LSPActive,
  Space,
  Location,
  Space,
  Git,
}

local StatusLines = {
  hl = function()
    if conditions.is_active() then
      return { bg = "mantle" }
    else
      return { bg = "surface0" }
    end
  end,
  static = {
    mode_colors = {
      n = "teal",
      i = "green",
      v = "mauve",
      V = "mauve",
      ["\22"] = "mauve",
      c = "peach",
      s = "flamingo",
      S = "flamingo",
      ["\19"] = "flamingo",
      R = "yellow",
      r = "yellow",
      ["!"] = "peach",
      t = "peach",
    },
    mode_color = function(self)
      local mode = vim.fn.mode():sub(1, 1)
      return self.mode_colors[mode] or "lavender"
    end,
  },
  fallthrough = false,
  -- SpecialStatusline,
  -- TerminalStatusline,
  InactiveStatusline,
  DefaultStatusline,
}

return StatusLines
