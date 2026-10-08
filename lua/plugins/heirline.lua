local heirline = require("heirline")
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local devicons = require("nvim-web-devicons")

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------
local function setup_colors()
  local c = require("catppuccin.palettes").get_palette()
  return {
    base = c.base,
    mantle = c.mantle,
    crust = c.crust,
    surface0 = c.surface0,
    surface1 = c.surface1,
    surface2 = c.surface2,
    overlay0 = c.overlay0,
    overlay1 = c.overlay1,
    overlay2 = c.overlay2,
    text = c.text,
    subtext0 = c.subtext0,
    subtext1 = c.subtext1,
    rosewater = c.rosewater,
    flamingo = c.flamingo,
    pink = c.pink,
    mauve = c.mauve,
    red = c.red,
    maroon = c.maroon,
    peach = c.peach,
    yellow = c.yellow,
    green = c.green,
    teal = c.teal,
    sky = c.sky,
    sapphire = c.sapphire,
    blue = c.blue,
    lavender = c.lavender,
    diag_error = c.red,
    diag_warn = c.yellow,
    diag_info = c.sky,
    diag_hint = c.sky,
  }
end

heirline.load_colors(setup_colors())

-- ---------------------------------------------------------------------------
-- Primitives
-- ---------------------------------------------------------------------------
local Space = { provider = " " }
local Align = { provider = "%=" }

local Mode = {
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
  end,
  static = {
    mode_names = {
      n = " NORMAL",
      no = " O-PENDING",
      nov = " O-PENDING",
      noV = " O-PENDING",
      ["no\22"] = " O-PENDING",
      niI = " NORMAL",
      niR = " NORMAL",
      niV = " NORMAL",
      nt = " NORMAL",
      v = "󰒉 VISUAL",
      vs = "󰒉 VISUAL",
      V = "󰒉 V-LINE",
      Vs = "󰒉 V-LINE",
      ["\22"] = "󰒉 V-BLOCK",
      ["\22s"] = "󰒉 V-BLOCK",
      s = "󰫙 SELECT",
      S = "󰫙 S-LINE",
      ["\19"] = "󰫙 S-BLOCK",
      i = " INSERT",
      ic = " INSERT",
      ix = " INSERT",
      R = "REPLACE",
      Rc = "REPLACE",
      Rx = "REPLACE",
      Rv = "V-REPLACE",
      Rvc = "V-REPLACE",
      Rvx = "V-REPLACE",
      c = " CMD",
      cv = " CMD",
      r = "REPLACE",
      rm = "MORE",
      ["r?"] = "CONFIRM",
      ["!"] = "SHELL",
      t = "TERM",
    },
    mode_colors = {
      n = "lavender",
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
  },
  provider = function(self)
    return "%2(" .. self.mode_names[self.mode] .. "%)"
  end,
  hl = function(self)
    local mode = self.mode:sub(1, 1) -- get only the first mode character
    return { fg = "base", bg = self.mode_colors[mode], bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
}
Mode = utils.surround({ "", "" }, function(self)
  return self:mode_color()
end, Mode)

-- File section
local FileIcon = {
  restrict = { hl = true },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = devicons.get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ") or ""
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}
local FileName = {
  restrict = { hl = true },
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":t")
    return filename == "" and "[No Name]" or filename
  end,
  hl = { bold = true },
}
local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = " [+]",
    hl = { fg = "yellow" },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = "  ",
    hl = { fg = "red" },
  },
}
local FileSection = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  hl = { bg = "mantle", fg = "text" },
  FileIcon,
  FileName,
  FileFlags,
}

local GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.ahead = vim.b.git_ahead or 0
    self.behind = vim.b.git_behind or 0

    local branch = self.status_dict.head or ""
    local ahead_str = self.ahead > 0 and (" \u{2191}" .. self.ahead) or ""
    local behind_str = self.behind > 0 and (" \u{2193}" .. self.behind) or ""
    local suffix = ahead_str .. behind_str .. " "

    self.full_str = " \u{e0a0} " .. branch .. suffix

    local trunc_branch = branch
    if #trunc_branch > 50 then
      trunc_branch = trunc_branch:sub(1, 47) .. "\u{2026}"
    end
    self.trunc_str = " \u{e0a0} " .. trunc_branch .. suffix

    self.icon_str = " \u{e0a0}" .. suffix
  end,
  flexible = 1,
  -- Full: icon + full branch name + ahead/behind
  {
    provider = function(self)
      return self.full_str
    end,
  },
  -- Truncated: up to 20 chars + ahead/behind
  {
    provider = function(self)
      return self.trunc_str
    end,
  },
  -- Icon only + ahead/behind
  {
    provider = function(self)
      return self.icon_str
    end,
  },
  -- Nothing when no space
  { provider = "" },
  hl = { fg = "mauve" },
  update = { "BufEnter", "FocusGained", "User", pattern = "GitSignsUpdate" },
}
local GitDiff = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
  end,
  update = { "User", pattern = "GitSignsUpdate" },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count .. " ") or ""
    end,
    hl = { fg = "green" },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count .. " ") or ""
    end,
    hl = { fg = "yellow" },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count .. " ") or ""
    end,
    hl = { fg = "red" },
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
    provider = " 󰑋 ",
    hl = { fg = "red", bold = true },
  },
  utils.surround({ "[", "]" }, "", {
    provider = function()
      return vim.fn.reg_recording()
    end,
    hl = { fg = "red", bold = true },
  }),
}
local Diagnostics = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = " ",
    warn_icon = " ",
    info_icon = " ",
    hint_icon = " ",
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  end,
  update = "DiagnosticChanged",
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

local FileEncoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
    return enc:upper()
  end,
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
}

local RightInfo = utils.surround({ "", "" }, function(self)
  return self:mode_color()
end, {
  hl = function(self)
    return { fg = "base", bg = self:mode_color(), bold = true }
  end,
  FileEncoding,
  { provider = "|" },
  FileFormat,
})

local Location = {
  provider = "%l/%L:%c %P ",
  hl = { fg = "peach" },
}

local ScrollBar = {
  static = {
    sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = "maroon", bg = "base" },
}

-- Default statusline for normal buffers
local DefaultStatusline = {
  Mode,
  Space,
  FileSection,
  GitBranch,
  GitDiff,
  MacroRec,
  Align,
  Diagnostics,
  Space,
  LSPActive,
  Space,
  -- Location,
  -- ScrollBar,
  Space,
  RightInfo,
}

-- Inactive statusline (dimmed, minimal with git context)
local InactiveStatusline = {
  condition = conditions.is_not_active,
  {
    provider = function()
      local path = vim.fn.expand("%:.")
      -- path = vim.fn.fnamemodify(path, ":.")
      return path
    end,
    hl = { fg = "blue", bold = true },
  },
  Align,
}

-- ===========================================================================
-- StatusLines (root: fallthrough = false, carries mode_color static)
-- ===========================================================================
local StatusLines = {
  hl = { bg = "mantle" },
  static = {
    mode_colors = {
      n = "lavender",
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

-- ===========================================================================
-- TabLine (Bufferline)
-- ===========================================================================

-- Buffer filename (tail only)
local TablineFileName = {
  provider = function(self)
    local filename = self.filename
    filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
    return filename
  end,
  hl = function(self)
    return { bold = self.is_active, italic = self.is_active }
  end,
}

-- Modified / readonly / terminal flags per-buffer
local TablineFileFlags = {
  {
    condition = function(self)
      return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
    end,
    provider = " 󰷥 ",
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr }) or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
    end,
    provider = function(self)
      if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
        return "  "
      else
        return "  "
      end
    end,
  },
}

-- Assemble filename block: icon + name + flags
local TablineFileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
  end,
  hl = function(self)
    if self.is_active then
      return { fg = "base", bg = "lavender" }
    else
      return { bg = "surface1", fg = "subtext0" }
    end
  end,
  FileIcon,
  TablineFileName,
  TablineFileFlags,
}

-- Wrap each buffer block in powerline surrounds matching the statusline style
local TablineBufferBlock = utils.surround({ " ", "" }, function(self)
  if self.is_active then
    return "lavender"
  else
    return "surface1"
  end
end, { TablineFileNameBlock })

-- Build the bufferline using heirline's make_buflist
local BufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = " ", hl = { fg = "overlay0" } }, -- left truncation
  { provider = " ", hl = { fg = "overlay0" } } -- right truncation
)

-- Tab pages (shown only when ≥2 tabs)
local Tabpage = {
  provider = function(self)
    return "%" .. self.tabnr .. "T " .. self.tabnr .. " T"
  end,
  hl = function(self)
    if self.is_active then
      return { fg = "text", bg = "surface1", bold = true }
    else
      return { fg = "overlay0", bg = "mantle" }
    end
  end,
}

local TabPages = {
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end,
  { provider = "%=" },
  utils.make_tablist(Tabpage),
}

local TabLineOffset = {
  condition = function(self)
    local win = vim.api.nvim_tabpage_list_wins(0)[1]
    local bufnr = vim.api.nvim_win_get_buf(win)
    self.winid = win
    if vim.bo[bufnr].filetype == "NvimTree" then
      self.title = "NvimTree"
      return true
    end
  end,
  provider = function(self)
    local title = self.title
    local width = vim.api.nvim_win_get_width(self.winid)
    local pad = math.ceil((width - #title) / 2)
    return string.rep(" ", pad) .. title .. string.rep(" ", pad)
  end,
  hl = function(self)
    if vim.api.nvim_get_current_win() == self.winid then
      return { fg = "text", bg = "surface1" }
    else
      return { fg = "overlay0", bg = "surface0" }
    end
  end,
}

local TabLine = {
  hl = { bg = "base" },
  TabLineOffset,
  BufferLine,
  Align,
  TabPages,
}

-- ===========================================================================
-- WinBar
-- ===========================================================================
local WinBarFileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = devicons.get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ") or ""
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

local PATH_SEP = package.config:sub(1, 1)

local function drop_leading(path, n)
  local pos = 1
  for _ = 1, n do
    pos = path:find(PATH_SEP, pos, true)
    if not pos then
      return nil
    end
    pos = pos + 1
  end
  return "\u{2026}" .. PATH_SEP .. path:sub(pos)
end

local WinBarFilePath = {
  flexible = 2,
  init = function(self)
    self.relpath = vim.fn.fnamemodify(self.filename, ":.")
    if self.relpath == "" then
      self.relpath = "[No Name]"
    end
    self.basename = vim.fn.fnamemodify(self.filename, ":t")
    if self.basename == "" then
      self.basename = "[No Name]"
    end
  end,
  {
    provider = function(self)
      return self.relpath
    end,
  },
  {
    provider = function(self)
      return drop_leading(self.relpath, 1) or self.basename
    end,
  },
  {
    provider = function(self)
      return drop_leading(self.relpath, 2) or self.basename
    end,
  },
  {
    provider = function(self)
      return drop_leading(self.relpath, 3) or self.basename
    end,
  },
  {
    provider = function(self)
      return drop_leading(self.relpath, 4) or self.basename
    end,
  },
  {
    provider = function(self)
      return drop_leading(self.relpath, 5) or self.basename
    end,
  },
  {
    provider = function(self)
      return self.basename
    end,
  },
  hl = { bold = true },
}

local WinBar = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  hl = function()
    if not conditions.is_active() then
      return { fg = "overlay0", force = true }
    end
  end,
  WinBarFileIcon,
  WinBarFilePath,
}

-- ===========================================================================
-- Setup
-- ===========================================================================
heirline.setup({
  statusline = StatusLines,
  winbar = WinBar,
  tabline = TabLine,
  opts = {
    disable_winbar_cb = function(args)
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = {
          "^git.*",
          "fugitive",
          "Trouble",
          "lazy",
          "alpha",
          "dashboard",
          "NvimTree",
        },
      }, args.buf)
    end,
  },
})
