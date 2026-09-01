# Neovim 配置说明

最后核对日期：2026-09-01

这份文档记录本项目当前的设计、各文件职责、关键实现取舍和快捷键风险。它既是配置索引，也是以后排查“这段代码为什么存在”的依据。

## 设计目标

项目目前主要面向 Go、Python 和 Lua 开发。配置采用以下分工：

- AstroCore 管理 Neovim 编辑器级能力：选项、普通快捷键、自动命令、诊断和 Treesitter。
- lazy.nvim 管理插件的安装与加载。
- 各插件文件只管理该插件自己的设置和需要触发延迟加载的快捷键。
- LSP 文件保留语言服务器配置及只在 LSP attach 后有效的 buffer 局部行为。

这并不等于使用完整 AstroNvim 发行版。项目仍然是独立的 Neovim 配置，只复用 `astrocore` 提供的配置框架和通用工具。

## 启动流程

1. `init.lua` 首先加载 `key_map.lua`，提前设置 Leader 键。
2. `init.lua` 加载 `commands.lua`，注册自定义用户命令。
3. `init.lua` 加载 `plugins`。
4. `lua/plugins/init.lua` 引导 lazy.nvim，并导入各插件模块。
5. AstroCore 应用编辑器级选项、快捷键、自动命令、诊断和 Treesitter 配置。
6. 其他插件根据启动条件或命令按需加载。

Leader 必须在 lazy.nvim 解析插件快捷键之前设置，因此 `key_map.lua` 是一个很小的启动前配置文件。

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

当前使用 `main` 分支，该分支不支持延迟加载。功能启用和解析器安装由 AstroCore 的适配层负责。当前启用的函数和类文本对象包括：

- `af`：函数整体。
- `if`：函数内部。
- `ac`：类整体。
- `ic`：类内部。

### `lua/commands.lua`

注册 `MessagesBuffer`、`Readme` 等自定义用户命令及其浮窗局部快捷键，使用户命令与插件管理逻辑相互独立。

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
- `ai_copilotchat.lua`：Copilot Chat 备用配置；导入行当前保持注释，不会加载。

插件内部快捷键可以继续留在插件 spec 的 `keys` 或 `config` 中。例如 Neo-tree 的 `<Leader>e` 同时承担延迟加载触发器，如果强行移入 AstroCore，反而会破坏 lazy.nvim 的按需加载语义。

## AstroCore 与原生 API 的职责边界

AstroCore 管理适合集中管理的核心能力，具体插件生命周期内的行为则直接使用 Neovim API。

以下情况直接调用 Neovim API：

- LSP attach 后创建 buffer 局部映射和自动命令。
- Neo-tree 节点操作等插件内部回调。
- nvim-cmp 根据补全菜单状态执行的复杂按键逻辑。
- DAP adapter 和调试事件监听。

AstroCore 是这些 API 的组织层，并不替代 Neovim API。

### 关于 buffer 关闭

独立安装 AstroCore 时，它不会像完整 AstroNvim 那样初始化 `vim.t.bufs` buffer 跟踪列表，因此不能直接调用依赖该列表的 `astrocore.buffer.close()`。项目使用 `Snacks.bufdelete` 安全删除 buffer，快捷键由 AstroCore 管理。`wipe = true` 保留“关闭后重新打开时获得新 buffer”的标签页语义，Snacks 负责选择替代 buffer、保护窗口布局并处理未保存提示。

`Space+Q` 在普通文件中使用 `Snacks.bufdelete` 安全删除 buffer；在 quickfix 或 location-list 结果窗口中关闭对应窗口。Bufferline 的鼠标叉号同样使用这套逻辑。`:q`/`:quit` 保留 Neovim 原义：关闭当前窗口，关闭最后一个窗口时退出 Neovim。Neo-tree 即使成为最后一个窗口也不会主动关闭 Neovim。

## 关键实现与取舍

| 位置 | 当前实现解决的问题 | 官方/插件已有能力 | 结论 |
| --- | --- | --- | --- |
| `lua/utils/buffer.lua` | 像 IDE 标签页一样 wipe buffer，同时保持窗口布局 | Snacks 提供 `Snacks.bufdelete({ wipe = true })`、`all()`、`other()` | **使用 Snacks 官方能力**。由它处理未保存提示、替代 buffer 和布局保护 |
| `lua/commands.lua` 的 `MessagesBuffer` | 把原生 `:messages` 全部内容放进可滚动、可复制的浮窗 | Snacks 有 `Snacks.notifier.show_history()` / notification picker | **保留**。Snacks 只保证保存经过 notifier 的通知，不等于完整的 `:messages` 历史；直接替换可能漏掉 `nvim_echo`、命令输出等消息 |
| `lua/plugins/lsp.lua` 的 `smart_references()` | 无引用时提示；单个引用直接跳；多个引用打开 quickfix；回车跳转后自动关闭列表 | Neovim 官方支持 `vim.lsp.buf.references(..., { on_list = ... })`；Snacks 提供 `Snacks.picker.lsp_references()` | **保留交互或改用 Picker 二选一**。当前 `on_list` 本身就是官方扩展点；Snacks 更短但会改变为统一 Picker 体验 |
| `lua/plugins/lsp.lua` 的引用高亮自动命令 | 停留时请求语义引用，移动后清除；异步完成后刷新滚动条 | Neovim 提供 `document_highlight()`/`clear_references()`，但仍需要事件触发；没有“自动显示到 nvim-scrollbar”的选项 | **保留**。事件部分是官方推荐模式；滚动条刷新属于跨插件集成 |
| `lua/plugins/scrollbar.lua` 的搜索同步 | 把 `*`、`#`、`/` 搜索结果持续画到滚动条，直到执行 `:noh` | nvim-scrollbar 自带依赖 `nvim-hlslens` 的 search handler；hlslens 官方要求在 `*`/`#` 映射后调用 `start()` | **使用官方集成**。关闭 hlslens 自己的行尾计数，并按官方映射启动 lens，以保留滚动条标记 |
| `lua/plugins/scrollbar.lua` 的 LSP 引用 handler | 读取 Neovim 语义引用 extmark，在滚动条上显示真正同一符号的引用，避免把同名文本混入 | nvim-scrollbar 没有内置 LSP document-highlight handler | **保留**。这是有价值的跨插件功能；但 `nvim.lsp.references` 命名空间名称属于实现细节，升级 Neovim 时需要复查 |
| `lua/plugins/neo_tree.lua` 的 `copy_selector` | 用 `Y` 选择并复制 basename、扩展名、文件名、相对/绝对路径或 URI 到系统剪贴板 | Neo-tree 的 `copy_to_clipboard` 是文件复制/粘贴队列，不是复制路径文本 | **保留**。二者功能不同，不应误替换 |
| `lua/plugins/neo_tree.lua` 的 `system_open` | 用操作系统默认应用打开节点 | 当前实现调用 Neovim 官方 `vim.ui.open()`；Neo-tree v3 没有等价的通用默认命令 | **保留**，实现已经足够简单且跨平台 |
| `lua/plugins/git.lua` 的 LazyGit 退出刷新 | LazyGit 修改仓库后刷新 filesystem、git_status、diagnostics；Windows 上又关闭了 libuv watcher | lazygit.nvim 提供 `vim.g.lazygit_on_exit_callback` | **使用官方回调**，在 LazyGit 退出后直接刷新 Neo-tree |
| `lua/plugins/breadcrumb.lua` 的启用判断 | 只在普通文件窗口显示 Dropbar，不占用 Neo-tree、Claude Code 或浮窗的 winbar | Dropbar 官方支持 `bar.enable` 函数 | **保留**。这已经是在使用插件原生选项 |
| `lua/plugins/breadcrumb.lua` 的全局开关 | 动态关闭所有现有 winbar，重新开启时触发重新附着 | Dropbar 提供 `bar.enable`，但没有完整等价的全局 toggle API | **保留**。手工刷新是为了让已打开窗口立刻响应 |
| `lua/plugins/code_completion.lua` 的 `<CR>`/`<Tab>` 回调 | Enter 只确认手动选中的候选；Tab 只跳 LuaSnip 占位符，不选择补全项 | nvim-cmp 通过 mapping 回调提供这类条件行为，没有一个布尔选项完全等价 | **保留**。这是明确的补全交互策略 |
| `lua/plugins/astrocore.lua` 的插入模式左右键 | 补全菜单显示时保持方向键语义；否则允许左右跨行 | Neovim 的 `whichwrap` 与表达式映射可实现；没有插件选项能同时表达这个条件 | **保留** |
| `lua/plugins/astrocore.lua` 的插入/离开模式诊断切换 | 输入时隐藏 virtual text，离开输入模式恢复 | `update_in_insert` 只控制诊断更新时间，不控制是否显示已有 virtual text | **保留** |
| `lua/plugins/term.lua` 的 `Alt+n` | ToggleTerm 中从终端输入模式进入普通模式，保留 `Esc` 给交互程序 | ToggleTerm 官方文档建议为退出终端模式设置 buffer-local mapping | **保留** |
| `lua/plugins/ai_claudecode.lua` 的 `Alt+n` 和窗口移动键 | Claude Code 终端中进入普通模式、跨窗口移动 | Claude Code 官方将 `snacks_win_opts` 透传给 Snacks window，并支持其中的 `keys` | **保留**。当前写法就是插件公开配置入口 |

## 快捷键风险

### 已确认的有意覆盖

1. `gr` 被设置成 `nowait = true` 的引用跳转。

   Neovim 0.12 的全局 LSP 默认键包括 `gra`（Code Action）、`gri`
   （Implementation）、`grn`（Rename）、`grr`（References）、`grt` 和 `grx`。
   当前两键 `gr` 会立即执行，因此所有以 `gr` 开头的三键默认映射都不可达。
   项目虽然另外映射了 `gi`、`<Leader>rn`、`<Leader>ca`，但 `grt`/`grx`
   会被遮蔽。用户已确认只需要无延迟的 `gr`，因此保持现状。

2. 插入模式 `<C-s>` 覆盖 Neovim 0.12 的 LSP `signature_help` 默认键。

   当前用途是保存文件，这是已确认的 IDE 风格选择。签名帮助如以后需要，可另设按键。

### 中优先级

- 普通模式 `<C-d>` 和 `<C-f>` 被改为跳转列表后退/前进，覆盖原生半页向下和整页向下。
- 普通模式 `<C-h/j/k/l>` 用于调整窗口，覆盖部分原生控制键语义；窗口移动实际使用 `<C-Left/Down/Up/Right>`。README 中的描述需要与实际配置保持一致。
- `<Leader>b` 是 DAP 断点，同时也是 `<Leader>ba`/`<Leader>bo` 的前缀。它们能共存，但单独按 `<Leader>b` 时可能等待 `timeoutlen`。
- `<C-S-z>` 在不同终端/键盘协议中不一定能与 `<C-z>` 区分，重做快捷键可能失效或被识别为撤销。

### 安全的局部覆盖

- Claude Code 与 ToggleTerm 的 `<A-n>` 只在各自终端 buffer 的 terminal mode 生效。
- Neo-tree 的 `[b`、`]b`、`Y`、`O` 和 fuzzy finder 的 `<C-j>/<C-k>` 是插件窗口局部映射。
- quickfix 中的 `<CR>` 只绑定到本次 LSP 引用结果 buffer。
- Messages 和 README 浮窗中的 `q`/`Esc` 只绑定到各自 buffer。
- git-conflict 的 `co`、`ct`、`cb`、`c0`、`[x`、`]x` 只在检测到冲突的文件中建立。

## 当前功能边界

- Go 仅由 gopls 提供格式化，避免与 none-ls/goimports 重复。
- Git 主界面只保留 LazyGit；gitsigns 和 git-conflict 分别负责行级提示与冲突处理。
- Claude Code 通过 `claudecode.nvim` 提供终端、上下文发送和 diff 审阅。
- Python 使用 Pyright 诊断和 Black 格式化。

## 待验证事项

1. 实际体验 hlslens 搜索滚动条是否仍符合预期。
2. 实际体验 Snacks 对未保存 buffer 的逐个提示，再决定是否长期保留。
3. 验证一次 LazyGit 修改文件并退出后，Neo-tree 是否立即刷新。
4. 保留已确认的 `gr`、`Ctrl+s`，以及 Neo-tree 路径选择器、Dropbar 动态开关、补全条件映射和终端 `<A-n>`。

## 常用检查命令

- `:checkhealth astrocore`：检查 AstroCore 配置和快捷键冲突。
- `:checkhealth nvim-treesitter`：检查 Treesitter 环境。
- `:Lazy`：查看插件加载与安装状态。
- `:Mason`：查看语言服务器和外部工具。
- `:LspInfo`：查看当前 buffer 的 LSP 状态。

如果某项行为与预期不同，优先从本文件的“核心配置位置”找到所属模块，再检查对应文件，而不是在整个项目中重复添加新实现。

## 参考资料

- [Neovim LSP defaults](https://neovim.io/doc/user/lsp/#lsp-defaults)
- [Snacks bufdelete](https://github.com/folke/snacks.nvim/blob/main/docs/bufdelete.md)
- [Snacks notifier](https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md)
- [Snacks picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
- [Neo-tree v3 configuration and mappings](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [Dropbar configuration](https://github.com/Bekaboo/dropbar.nvim)
- [nvim-scrollbar search integration](https://github.com/petertriho/nvim-scrollbar)
- [ToggleTerm configuration](https://github.com/akinsho/toggleterm.nvim)
- [Claude Code terminal/window configuration](https://github.com/coder/claudecode.nvim)
- [lazygit.nvim exit callback](https://github.com/kdheepak/lazygit.nvim)
