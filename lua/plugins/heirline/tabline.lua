local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local devicons = require("nvim-web-devicons")
-- ---------------------------------------------------------------------------
-- Primitives
-- ---------------------------------------------------------------------------
local Space = { provider = " " }
local Align = { provider = "%=" }

local FileIcon = {
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

return TabLine
