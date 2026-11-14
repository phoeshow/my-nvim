# AGENTS.md — my-nvim

面向在此仓库中工作的编码 Agent。**先读本文件，再读 `README.md`**（README 是完整的功能/键位手册，本文件只限定代码的修改要求，测试方式和禁止做哪些事情）。

## 1. 项目概览

- 这是一份个人使用的Neovim配置文件。纯lua实现。
- 只使用`nvim-0.12`版本开始内置的插件管理器控制插件的安装，不使用其他管理方案。
- 插件懒加载规则由`lua/core/pack.lua`中所提供的工具控制。
- 尽量使用匹配`neovim`最新正式发布版本推荐的新API，不做早期版本的降级。

## 2. 代码约定

- 格式：**stylua**，规则见 `.stylua.toml`（2 空格、双引号、列宽 160、Unix 换行）。提交前必须格式化。
- 键位：自定义按键映射必须包含 `desc` 字段描述作用。
- 颜色统一取自 catppuccin palette（`require("catppuccin.palettes").get_palette("mocha")`），heirline 用 `heirline.load_colors` 注入的具名色（`"peach"`、`"mantle"` 等）。不要硬编码 hex。
- 注释风格：中文说明 + `-- ====` / `-- ----` 分节；保持现有密度，不要给明显的代码加废话注释。

## 3. 新增或调整插件的标准流程

1. 在 `lua/plugins/init.lua` 的 `vim.pack.add` 里加 URL（仓库不在默认 master 时显式写 `name`/`version`）。
2. 在 `pack.setup` 注册表里选时机：UI 类 → `UIEnter`；文件相关 → `{ "BufReadPre", "BufNewFile" }`；补全 → `InsertEnter`；重插件 → `keys` 或 `defer`。
3. `packadd` 列表要包含该模块 `require` 到的**全部**插件目录，含传递依赖（例如 `nvim-web-devicons`、`plenary.nvim`）。漏写会在 `pack.lua` 里被 `pcall` 捕获成 `vim.notify` 的 ERROR，不会崩但功能静默缺失。

## 4. 关键陷阱（改之前务必知道）

- **不要在没有 `packadd` 的模块顶层 `require` 插件**：`vim.pack.add` 的 `load = function() end` 意味着未 `packadd` 的插件不在 runtimepath 上。
- 不要调整`catppuccin`、`nvim-tree`和`snacks`插件的加载时机。
- `nvim-pack-lock.json` 已被 `.gitignore` 忽略且未纳入版本控制。**不要提交它，也不要手改**；它由 `vim.pack` 维护。
- `conform` 在 `BufWritePre` 自动格式化（lua→stylua，js/ts/md/html/yaml/toml/css/json→oxfmt）。在 Neovim 里编辑本仓库的 lua 文件时保存即被 stylua 改写——这是预期行为。
- `core/autocmd.lua` 的 `PackChanged` 只处理 `nvim-treesitter`（安装/更新后自动 `TSUpdate`）。加其他插件的 post-install 钩子请扩展这里，不要新建散落的 `PackChanged`。

## 7. 验证方式

本仓库**没有测试、CI、Makefile、justfile**，也不要新增。改动的效果由用户亲自手动验证。

格式化（stylua 由 mason 安装，不在 PATH 上）：

```bash
~/.local/share/nvim/mason/bin/stylua .
```

## 8. 提交与边界

- 提交信息沿用现有风格：**单行、英文、小写开头、无前缀**（例：`add grug-far.nvim for search and replace`）。不加 emoji、不加 Conventional Commits 前缀。
- **不要** `git push`、发布、或执行任何对外可见操作，除非用户明确要求。
- 只改与当前任务相关的文件；不重构未要求重构的代码，不动 `core/options.lua` 的既有选项值，不改 leader 键。
