local conditions = require("heirline.conditions")
local devicons = require("nvim-web-devicons")
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

return WinBar
