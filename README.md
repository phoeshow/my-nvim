# Neovim 配置说明

基于 **Neovim 原生 `vim.pack`** 的模块化配置，无 lazy.nvim 等插件管理器。
Leader 键为 `<Space>`，localleader 同为 `<Space>`。

## 目录结构

```
init.lua                    入口：loader、leader、禁用内置插件、require 各模块
lua/core/
  options.lua               全局选项 + diagnostic 配置
  keymaps.lua               通用快捷键（无插件依赖）
  autocmd.lua               yank 高亮、输入法切换、q 关闭窗口、TSUpdate
  pack.lua                  自研声明式加载引擎（事件/按键/延迟/立即）
lua/plugins/
  init.lua                 vim.pack.add 声明全部插件 + 加载注册表
  catppuccin.lua           主题
  snacks.lua               大杂烩：picker/dashboard/indent/scope/toggle
  navigator.lua            smart-splits 跨 tmux 窗格导航
  nvim-tree.lua            文件树
  ui.lua                   which-key / colorizer / outline / todo / markdown 模块函数
  lsp.lua                  mason + lspconfig + lazydev + fidget
  completion.lua           blink.cmp
  editing.lua              conform / lint / autopairs / autotag / flash / grug-far
  git.lua                  gitsigns / diffview
  treesitter.lua           内置 treesitter API，按需自动安装 parser
  heirline/                手写 statusline / winbar / tabline
  lualine.lua              备用状态栏（当前未启用）
nvim-pack-lock.json         插件锁文件（版本/commit 固定，已被 .gitignore 忽略）
.stylua.toml                格式化规则：2 空格、双引号、列宽 160
```

## 核心配置

### 入口 `init.lua`
- `vim.loader.enable()` 启用 Lua 字节码缓存，加速启动。
- 屏蔽大量内置插件：`netrw`、`zip/tar`、`gzip`、`getscript`、`matchit` 等。
- 加载顺序：`core.options` → `core.keymaps` → `core.autocmd` → `plugins`。

### 选项要点（`core/options.lua`）
| 类别 | 设置 |
|---|---|
| 行号 | `number` + `relativenumber`，`signcolumn=yes` |
| 滚动 | `scrolloff=8`，`sidescrolloff=5` |
| 缩进 | 2 空格，`expandtab`/`smarttab`/`softtabstop=2`，`breakindent` |
| 搜索 | `ignorecase` + `smartcase` |
| 分屏 | `splitright`、`splitbelow` |
| 外观 | `termguicolors`、`cursorline`、`showmode=false`、`showtabline=2`、不换行 |
| 空白 | `list` + `listchars`：`tab=» `、`trail=·`、`nbsp=␣` |
| 响应 | `updatetime=250`，`timeoutlen=300`（leader 序列等待） |
| 折叠 | `foldenable=false` |
| 编码 | `utf-8`，读取兼容 `cp936/gb18030/big5/euc-jp/euc-kr` |
| 剪贴板 | `clipboard=unnamedplus`（schedule 延迟设置） |

### Diagnostic
- 图标：Error `󰅚` / Warn `󰀪` / Info `󰋽` / Hint `󰌶`
- `virtual_text=true`，错误用下划线，浮窗 `border=single`
- `jump.on_jump`：用 `]d`/`[d` 跳转时自动弹出浮窗

### Autocmd
- `TextYankPost` → 复制高亮
- `InsertLeave`/`CmdlineLeave` → Linux 调 `fcitx5-remote -c`，macOS 调 `macism` 切回英文输入法
- `FileType`（help/checkhealth/lspinfo/qf/startuptime）→ `q` 关闭并删除 buffer
- `PackChanged` → `nvim-treesitter` 安装/更新后自动 `TSUpdate`

## 插件加载机制（`core/pack.lua`）

不是懒加载框架，而是一个轻量声明式引擎：

1. `lua/plugins/init.lua` 用 `vim.pack.add({...}, { load = function() end })` 只做**下载/锁定**，不加载 runtimepath。
2. `pack.setup(registry)` 遍历注册表，每条 entry 支持：
   - `packadd = {...}`：需要时 `:packadd` 加入 runtimepath（带去重）
   - `event` / `pattern` / `once`：autocmd 触发加载（默认一次性）
   - `keys = {{key, desc, mode}}`：设置临时键位，首次按下才加载并 `feedkeys` 重放
   - `defer = ms`：`vim.defer_fn` 延迟加载
   - 无以上字段：启动时立即加载
   - `fn = "xxx"`：加载模块后调用其导出函数（一个文件可拆多个加载入口）
3. 加载有 `loaded` 去重表，失败用 `vim.notify` 报错不崩溃；`require("core.pack").loaded()` 可调试。

### 各插件加载时机

| 时机 | 模块 / 插件 |
|---|---|
| 立即 | catppuccin、snacks、navigator(smart-splits) |
| `VimEnter` | nvim-tree |
| `UIEnter` | heirline、ui.which_key |
| `BufReadPre`/`BufNewFile` | lsp、treesitter、gitsigns、flash、lint、autotag；`*.lua` 额外加载 lazydev；fidget |
| `InsertEnter`/`CmdlineEnter` | blink.cmp、autopairs |
| `BufWritePre` | conform（保存时格式化） |
| 首次按键 | diffview（`<leader>gd`/`<leader>gh`）、grug-far（`<leader>sr`） |
| `FileType markdown*` | render-markdown |
| 延迟 120/150ms | colorizer、outline、todo-comments |
| 未启用 | lualine（已被 heirline 取代，注册表里注释掉） |

## 快捷键总览

### 基础（`core/keymaps.lua`）
| 键 | 功能 |
|---|---|
| `<S-h>` / `<S-l>` | 上一个 / 下一个 buffer |
| `<leader>wh` 或 `<leader>w-` | 水平分屏 |
| `<leader>wv` 或 `<leader>w\` | 垂直分屏 |
| `<leader>wd` | 关闭窗口 |
| `<leader>yf` | 复制当前文件的相对路径和光标所在的行号，格式类似`lua/plugins/init.lua#L10` |
| `<C-Up/Down/Left/Right>` | 调整窗口高 / 宽 |
| `<A-j>` / `<A-k>` | 下移 / 上移当前行（可视模式保持选区） |
| `x` | 删除字符但不写入寄存器 |
| `p`(可视) | 粘贴不覆盖寄存器 |
| `j` / `k` | 无计数时按屏幕行移动（`gj`/`gk`） |
| `<` / `>` | 缩进后保持选区 |
| `<Esc>` | 清除搜索高亮 |

### 窗口导航（smart-splits）
| 键 | 功能 |
|---|---|
| `<C-h/j/k/l>` | 在 Neovim 分屏与 tmux 窗格之间自由移动 |

### 文件树 nvim-tree
| 键 | 功能 |
|---|---|
| `<leader>e` | 打开/关闭文件树 |
| `?` | 帮助（替换默认 `g?`） |
| `<C-s>` | 水平分屏打开（替换默认 `<C-x>`，`<C-t>` 已移除） |

### 搜索 / Picker（snacks）
| 键 | 功能 |
|---|---|
| `<leader>ff` | 查找文件（排除 node_modules） |
| `<leader>fg` | 全文搜索（live grep） |
| `<leader>fb` | buffer 列表 |
| `<leader>fh` | help 标签 |
| `<leader>fk` | 键位列表 |
| `<leader>fn` | Neovim 配置文件 |
| `<leader>f"` | 寄存器 |
| `<leader>fi` | 图标 |
| `<leader>fd` / `<leader>fD` | 诊断（当前 buffer / 工作区） |
| `<leader>ft` | TODO 快速修复列表 |
| `<leader>bd` | 删除 buffer |

### Git
| 键 | 功能 |
|---|---|
| `<leader>gl` | Lazygit |
| `<leader>gb` | 当前行 blame |
| `<leader>gd` | Diffview 打开 |
| `<leader>gh` | 当前文件历史 |
| `]c` / `[c` | 下一个 / 上一个 hunk |
| `<leader>hs` / `<leader>hr` | stage / reset hunk（支持可视选区） |
| `<leader>hS` / `<leader>hR` | stage / reset 整个 buffer |
| `<leader>hp` | 预览 hunk |
| `<leader>tb` | 切换行内 blame |

### LSP（`LspAttach` 后 buffer 内生效）
| 键 | 功能 |
|---|---|
| `gd` / `gD` / `gr` / `gI` / `gt` | 定义 / 声明 / 引用 / 实现 / 类型定义（均用 snacks picker） |
| `K` | hover 文档（single 边框） |
| `<leader>ca` | code action |
| `<leader>cr` | 重命名 |

### 编辑
| 键 | 功能 |
|---|---|
| `s` / `S` | flash 跳转 / treesitter 节点跳转（n/x/o 模式） |
| `<leader>sr` | grug-far 全局搜索替换 |

### 开关类（snacks.toggle，`UIEnter` 后注册）
| 键 | 功能 |
|---|---|
| `<leader>uw` | 自动换行 |
| `<leader>uL` | 相对行号 |
| `<leader>ud` | 诊断 |
| `<leader>ul` | 行号 |
| `<leader>uc` | conceallevel |
| `<leader>th` | inlay hints |
| `<leader>tc` | colorizer 附加/分离 |
| `<leader>to` | outline 大纲 |
| `<leader>ft` | TODO |

### 其他
| 键 | 功能 |
|---|---|
| `q` | 在 help/qf/checkhealth/lspinfo 等窗口关闭 |

> 输入 `Space` 后 which-key 会提示分组：`c` Code、`f` Find、`w` Window、`b` Buffer、`g` Git、`h` Git Hunk、`t` Toggle、`u` UI、`d` Debug、`s` Search。

## 各插件作用

**主题与外观**
- `catppuccin`：Mocha 风格，透明背景，自定义 cursorline / blink / nvim-tree / indent 高亮
- `heirline.nvim`：手写 statusline（模式块、文件名、诊断、宏录制、编码、文件格式、LSP、位置、git 分支与增删改）、winbar（图标 + 自适应相对路径，最多裁掉 5 级目录）、tabline（buffer 列表 + 多 tab 页，NvimTree 侧显示标题偏移）
- `nvim-web-devicons`：文件类型图标
- `which-key.nvim`：leader 分组提示
- `nvim-colorizer.lua`：颜色值内联显示（延迟 120ms）
- `outline.nvim`：符号大纲（延迟 150ms）
- `render-markdown.nvim`：Markdown 渲染

**文件与搜索**
- `snacks.nvim`：一体式套件，启用 bigfile / input / notifier / quickfile / statuscolumn / words / indent / scroll / picker / image / scope（`ii`/`ai` 文本对象）/ dashboard（自定义 header 与快捷项）
- `nvim-tree.lua`：文件树，打开文件后自动关闭，显示缩进标记，自定义 git 图标，隐藏 dotfiles 但显示 gitignore 文件，重命名时同步 `Snacks.rename`

**LSP / 补全**
- `mason.nvim` + `mason-lspconfig.nvim` + `mason-tool-installer.nvim`：自动安装管理 lua_ls、vtsls、rust_analyzer、tailwindcss、cssls、html，以及 stylua、eslint_d、oxfmt
- `nvim-lspconfig`：使用新版 `vim.lsp.config` API 配置
- `lazydev.nvim`：Lua 开发补全 luv/snacks 库（检测到 `.luarc.json` 时禁用）
- `fidget.nvim`：LSP 进度提示
- `blink.cmp`：补全，`enter` 预设键位，`<C-s>` 显示/隐藏文档，来源 lsp/path/snippets/buffer，fuzzy 用 Rust 实现，自动括号
- `friendly-snippets`：内置代码片段

**语法与编辑**
- `nvim-treesitter`（main 分支）：不用旧式 `configs.setup`，自写 `FileType` autocmd —— 已装 parser 直接 attach，未装但可用则 `install():await()` 后 attach，并启用 treesitter 缩进
- `nvim-autopairs` / `nvim-ts-autotag`：自动括号、HTML/JSX 标签
- `flash.nvim`：`s`/`S` 快速跳转
- `grug-far.nvim`：项目级搜索替换，自动按当前文件扩展名过滤

**格式化 / 检查**
- `conform.nvim`：保存时格式化，`lsp_format=fallback`；lua→stylua，js/ts/jsx/tsx/md/html/yaml/toml/css/json/jsonc→oxfmt
- `nvim-lint`：js/ts/jsx/tsx 用 `eslint_d`，在 `BufEnter`/`BufWritePost`/`InsertLeave` 触发且仅在可修改 buffer

**Git**
- `gitsigns.nvim`：hunk 导航、stage/reset、行内 blame
- `diffview.nvim`：diff 视图与文件历史，merge tool 用 `diff3_mixed`

**窗口**
- `smart-splits.nvim` + `backend-tmux`：`<C-h/j/k/l>` 无缝穿越 Neovim 分屏与 tmux 窗格

## 维护提示

- 新增插件：在 `lua/plugins/init.lua` 的 `vim.pack.add` 中加 URL，再在 `pack.setup` 注册表里选加载时机。
- 一个 lua 文件可导出多个 `M.xxx()` 函数，配多个不同加载时机的注册项（见 `lsp.lua`、`editing.lua`、`ui.lua`）。
- 版本固定见 `nvim-pack-lock.json`（已被 git 忽略，本地保留即可复现）。
- 格式化本配置：`stylua .`（规则见 `.stylua.toml`）。
