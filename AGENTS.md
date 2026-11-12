# AGENTS.md — my-nvim

面向在此仓库中工作的编码 Agent。**先读本文件，再读 `README.md`**（README 是完整的功能/键位手册，本文件只讲"怎么改、怎么验、别踩什么"）。

## 1. 项目概览

- 个人 Neovim 配置，纯 Lua，无插件管理器（**不用 lazy.nvim / packer / vim-plug**）。
- 插件通过 Neovim 原生 `vim.pack.add` 下载与锁定，加载时序由自研引擎 `lua/core/pack.lua` 声明式控制。
- Leader / localleader 均为 `<Space>`，由 `init.lua` 设置，不要在别处改。
- 运行环境：已用 **NVIM v0.12.6**（LuaJIT）。代码依赖的新 API：`vim.pack.add`、`vim.lsp.config`、`vim.hl.on_yank`、`vim.treesitter.language.add`、`vim.treesitter.start`。**不要为了兼容 0.10 及更早版本降级这些 API。**

## 2. 目录与加载链路

```
init.lua              loader → leader → 禁用内置插件 → core.options → core.keymaps → core.autocmd → plugins
lua/core/             与插件无关的基础设施（options/keymaps/autocmd/pack 引擎）
lua/plugins/init.lua  唯一的插件清单（vim.pack.add）+ 唯一的加载注册表（pack.setup）
lua/plugins/*.lua     单个插件或功能域的配置
lua/plugins/heirline/ 手写 statusline/winbar/tabline（init 装配，其余三个文件各自 return 一段组件表）
```

`plugins/init.lua` 的两段式是**本仓库的核心模式**，改动任何插件都必须同时考虑这两处：

1. `vim.pack.add({...}, { confirm = false, load = function() end })` — 只做下载/锁定，`load` 是空函数，**插件不会被加入 runtimepath**。
2. `pack.setup(registry)` — 每个 entry 在合适的时机 `:packadd` 并 `require("plugins." .. mod)`。

entry 支持的字段（见 `core/pack.lua` 顶部注释）：

| 字段 | 语义 |
|---|---|
| `packadd = {...}` | 加载前 `:packadd` 这些目录名（去重，需写**目录名**如 `gitsigns.nvim`，不是 require 名） |
| `event` / `pattern` / `once` | autocmd 触发加载，`once` 默认 `true`（`BufWritePre` 这类需 `once = false`） |
| `keys = { { "<key>", mode = {...}, desc = "..." } }` | 首次按键加载后 `feedkeys` 重放；键位在**第一个位置参数** |
| `defer = 120` | `vim.defer_fn` 延迟加载 |
| `fn = "xxx"` | `require` 后调用模块导出函数；同一文件可注册多条不同时机的 entry（去重键为 `mod.fn`） |
| 以上皆无 | 启动时立即加载 |

## 3. 代码约定

- 格式：**stylua**，规则见 `.stylua.toml`（2 空格、双引号、列宽 160、Unix 换行）。提交前必须格式化。
- `lua/core/*.lua` 是**副作用脚本**（直接执行，无 `return M`）；`lua/plugins/*.lua` 按需写成：
  - 整文件副作用（如 `snacks.lua`、`nvim-tree.lua`、`lsp.lua` 主体），或
  - `local M = {}` + `function M.xxx()` + `return M`，供 `fn` 注册项调用（`ui.lua`、`editing.lua`、`git.lua` 的主体、`lsp.lua` 尾部）。
  - 一个模块里既有顶层副作用又有 `M.xxx()` 是可以的（`lsp.lua` 即如此），但**顶层副作用只会在该文件第一次被 require 时执行一次**，不要指望 `fn` 触发能重跑它。
- 键位：一律带 `desc`（which-key 依赖它）；新增 leader 分组时同步更新 `ui.lua` 的 `which_key()` spec。
- 颜色统一取自 catppuccin palette（`require("catppuccin.palettes").get_palette("mocha")`），heirline 用 `heirline.load_colors` 注入的具名色（`"peach"`、`"mantle"` 等）。不要硬编码 hex。
- 注释风格：中文说明 + `-- ====` / `-- ----` 分节；保持现有密度，不要给明显的代码加废话注释。

## 4. 新增或调整插件的标准流程

1. 在 `lua/plugins/init.lua` 的 `vim.pack.add` 里加 URL（仓库不在默认 master 时显式写 `name`/`version`）。
2. 在 `pack.setup` 注册表里选时机：UI 类 → `UIEnter`；文件相关 → `{ "BufReadPre", "BufNewFile" }`；补全 → `InsertEnter`；重插件 → `keys` 或 `defer`。
3. `packadd` 列表要包含该模块 `require` 到的**全部**插件目录，含传递依赖（例如 `nvim-web-devicons`、`plenary.nvim`）。漏写会在 `pack.lua` 里被 `pcall` 捕获成 `vim.notify` 的 ERROR，不会崩但功能静默缺失。
4. 需要新键位时同步更新 `README.md` 的键位表（README 是用户手册，不是可选项）。
5. 重启 Neovim 验证，不要依赖热重载（本配置没有热重载机制）。

## 5. 关键陷阱（改之前务必知道）

- **不要在没有 `packadd` 的模块顶层 `require` 插件**：`vim.pack.add` 的 `load = function() end` 意味着未 `packadd` 的插件不在 runtimepath 上。
- `lua/plugins/nvim-tree.lua`、`lua/plugins/lsp.lua`、`lua/plugins/snacks.lua` 里用了全局 `Snacks`（未 `require`）。前提是 `snacks` 在注册表中**立即加载**；调整加载顺序会让这些文件报 nil 索引。
- `heirline` 注册项未 `packadd` `nvim-web-devicons`，而是靠 `nvim-tree` 在 `VimEnter` 时顺带加入 runtimepath。调整这两者时机（尤其改成 `UIEnter` 之前触发）会破坏它。
- `lua/plugins/ui.lua` 的 `M.bufferline` 与整个 `lua/plugins/lualine.lua` 是**历史遗留/未启用代码**（bufferline 已从清单移除，heirline 取代 lualine）。除非任务明确要求，不要"顺手清理"或修改它们。
- `nvim-pack-lock.json` 已被 `.gitignore` 忽略且未纳入版本控制。**不要提交它，也不要手改**；它由 `vim.pack` 维护。
- `conform` 在 `BufWritePre` 自动格式化（lua→stylua，js/ts/md/html/yaml/toml/css/json→oxfmt）。在 Neovim 里编辑本仓库的 lua 文件时保存即被 stylua 改写——这是预期行为。
- `core/autocmd.lua` 的 `PackChanged` 只处理 `nvim-treesitter`（安装/更新后自动 `TSUpdate`）。加其他插件的 post-install 钩子请扩展这里，不要新建散落的 `PackChanged`。

## 6. 验证方式

本仓库**没有测试、CI、Makefile、justfile**，也不要新增。每次完成改动任务后由用户手动验证功能是否正确。

格式化（stylua 由 mason 安装，不在 PATH 上）：

```bash
~/.local/share/nvim/mason/bin/stylua .
```

改动涉及 UI（heirline / snacks / nvim-tree / blink）时，提示用户必须在真实终端打开 Neovim 目视确认，并在报告中说明确认了什么。

## 7. 提交与边界

- 提交信息沿用现有风格：**单行、英文、小写开头、无前缀**（例：`add grug-far.nvim for search and replace`）。不加 emoji、不加 Conventional Commits 前缀。
- **不要** `git push`、发布、或执行任何对外可见操作，除非用户明确要求。
- 只改与当前任务相关的文件；不重构未要求重构的代码，不动 `core/options.lua` 的既有选项值，不改 leader 键。
- 遇到不确定的插件 API（`vim.pack`、blink.cmp、snacks、heirline 等更新频繁）先查文档（context7）或读本地插件源码（`~/.local/share/nvim/site/pack/core/opt/*`），不要凭记忆写。
