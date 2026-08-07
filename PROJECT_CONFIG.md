# Neovim 配置说明

这份文档记录本项目的设计、各文件职责，以及从手写原生配置迁移到 AstroCore 后的对应关系。它既是配置索引，也是以后排查“这段代码为什么存在”的依据。

## 设计目标

项目目前主要面向 Go、Python 和 Lua 开发。配置采用以下分工：

- AstroCore 管理 Neovim 编辑器级能力：选项、普通快捷键、自动命令、诊断和 Treesitter。
- lazy.nvim 管理插件的安装与加载。
- 各插件文件只管理该插件自己的设置和需要触发延迟加载的快捷键。
- LSP 文件保留语言服务器配置及只在 LSP attach 后有效的 buffer 局部行为。

这并不等于使用完整 AstroNvim 发行版。项目仍然是独立的 Neovim 配置，只复用 `astrocore` 提供的配置框架和通用工具。

## 启动流程

1. `init.lua` 首先加载 `key_map.lua`，提前设置 Leader 键。
2. `init.lua` 加载 `plugins`。
3. `lua/plugins/init.lua` 引导 lazy.nvim，并导入各插件模块。
4. AstroCore 应用编辑器级选项、快捷键、自动命令、诊断和 Treesitter 配置。
5. 其他插件根据启动条件或命令按需加载。

Leader 必须在 lazy.nvim 解析插件快捷键之前设置，因此 `key_map.lua` 仍作为一个很小的启动前配置文件存在。

## 核心配置位置

### `lua/plugins/astrocore.lua`

这是当前项目的核心入口，包含：

- 窗口移动与窗口大小调整快捷键。
- Bufferline 切换、按编号跳转和按当前内容类型关闭的快捷键。
- `:q`/`:quit` 保留 Neovim 原生命令语义。
- 插入模式左右方向键跨行移动逻辑。
- 行号、缩进、搜索、剪贴板、鼠标、滚动边距等基础选项。
- 代码文件关闭自动换行、文本文件开启友好换行的 FileType 自动命令。
- 插入模式隐藏诊断文字、普通模式恢复诊断文字的自动命令。
- 全局诊断显示策略。
- Treesitter 解析器、高亮、缩进和文本对象。

### `lua/plugins/lsp.lua`

负责真正属于 LSP 生命周期的内容：

- Mason 安装 `gopls`、`pyright` 和 `lua_ls`。
- 三种语言服务器的设置。
- LSP attach 后才建立的 buffer 局部快捷键。
- 光标停留时调用语言服务器高亮同一符号的引用。

引用高亮不能用一个普通选项替代。标准方式就是监听 `CursorHold` 调用 `vim.lsp.buf.document_highlight()`，移动光标后清除引用。

### `lua/plugins/treesitter.lua`

只声明新版 `nvim-treesitter` 和 `nvim-treesitter-textobjects` 插件本身。

当前使用的是不兼容旧配置的 `main` 分支，它不支持延迟加载。功能启用和解析器安装由 AstroCore 的新版适配层负责，不再向 `require("nvim-treesitter").setup()` 传递旧版模块配置。

旧版的 `incremental_selection` 模块已从 main 分支移除，因此原来的 `<CR>` 扩大节点和 `<BS>` 缩小节点映射没有继续保留。函数和类文本对象仍然可用：

- `af`：函数整体。
- `if`：函数内部。
- `ac`：类整体。
- `ic`：类内部。

### 其他插件文件

- `code_completion.lua`：nvim-cmp、LuaSnip 和命令行补全。
- `none_ls.lua`：外部格式化器桥接。
- `daps.lua`：Go/Python 调试器及 DAP UI。
- `neo_tree.lua`：文件树及其内部操作。
- `git.lua`：Git 相关插件。
- `status.lua`：lualine 和 bufferline 的外观设置。
- `term.lua`：ToggleTerm。
- `subject_skin.lua`：Catppuccin 主题。
- `ai_claudecode.lua`：Claude Code IDE 集成。

插件内部快捷键可以继续留在插件 spec 的 `keys` 或 `config` 中。例如 Neo-tree 的 `<Leader>e` 同时承担延迟加载触发器，如果强行移入 AstroCore，反而会破坏 lazy.nvim 的按需加载语义。

## 手写配置到 AstroCore 的迁移对照

| 原位置或实现 | 当前位置或实现 | 原因 |
| --- | --- | --- |
| `set_up.lua` 中的 `vim.opt` | `astrocore.lua` 的 `opts.options.opt` | 统一管理编辑器选项 |
| `set_up.lua` 中的 FileType autocmd | `opts.autocmds` | 自动命令集中且自带 augroup 管理 |
| 手写诊断全局配置 | `opts.diagnostics` | AstroCore 原生支持 `vim.diagnostic.config()` 参数 |
| 插入模式诊断切换 autocmd | `opts.autocmds.diagnostics_by_mode` | 仍需事件驱动，但由 AstroCore 注册 |
| 手写 buffer 关闭 | `mini.bufremove.delete()` | 使用 AstroCore 兼容的专用模块并保持窗口布局 |
| 旧版 Treesitter 模块配置 | `opts.treesitter` | AstroCore 已适配 Treesitter main 新 API |
| 分散的普通快捷键 | `opts.mappings` | 统一描述、规范化键名并可执行冲突健康检查 |

## 为什么仍有少量原生代码

全面采用 AstroCore 的含义是让它管理适合集中管理的核心能力，而不是禁止使用 Neovim API。

以下情况继续直接调用 Neovim API是合理的：

- LSP attach 后创建 buffer 局部映射和自动命令。
- Neo-tree 节点操作等插件内部回调。
- nvim-cmp 根据补全菜单状态执行的复杂按键逻辑。
- DAP adapter 和调试事件监听。

AstroCore 本身也是对这些 API 的组织层，而不是替代 Neovim API 的另一套编辑器。

### 关于 buffer 关闭

独立安装 AstroCore 时，它不会像完整 AstroNvim 那样初始化 `vim.t.bufs` buffer 跟踪列表，因此不能直接调用依赖该列表的 `astrocore.buffer.close()`。项目使用 AstroCore 明确兼容的 `mini.bufremove` 模块安全删除 buffer；快捷键仍由 AstroCore 管理。这样既避免维护大段自定义关闭逻辑，也不会破坏窗口布局。

`Space+Q` 在普通文件中使用 `mini.bufremove` 安全删除 buffer；在 quickfix 或 location-list 结果窗口中关闭对应窗口。Bufferline 的鼠标叉号同样使用 `mini.bufremove`。`:q`/`:quit` 保留 Neovim 原义：关闭当前窗口，关闭最后一个窗口时退出 Neovim。Neo-tree 即使成为最后一个窗口也不会主动关闭 Neovim。

## 已完成的精简

- Go 仅由 gopls 提供格式化，避免与 none-ls/goimports 重复。
- Git 主界面只保留 LazyGit；gitsigns 和 git-conflict 分别负责行级提示与冲突处理。
- Claude Code 通过 `claudecode.nvim` 提供终端、上下文发送和 diff 审阅。
- Python 使用 Pyright 诊断和 Black 格式化，不再维护自定义 flake8 适配器。

## 常用检查命令

- `:checkhealth astrocore`：检查 AstroCore 配置和快捷键冲突。
- `:checkhealth nvim-treesitter`：检查 Treesitter 环境。
- `:Lazy`：查看插件加载与安装状态。
- `:Mason`：查看语言服务器和外部工具。
- `:LspInfo`：查看当前 buffer 的 LSP 状态。

如果某项行为与预期不同，优先从本文件的“核心配置位置”找到所属模块，再检查对应文件，而不是在整个项目中重复添加新实现。
